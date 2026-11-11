import { beforeEach, describe, expect, it, vi } from 'vitest';

import { handle, type Dependencies, type Env } from '../src/index';
import { clearWeatherCache } from '../src/weather';

const ANDROID = '1:1085118524930:android:03876253e309dc1daf011b';
const IOS = '1:1085118524930:ios:a8022d8e2cb93f65af011b';
const form = { startDate: '2026-11-10', lengthInDays: 2, accommodation: 'Deira', interests: ['Spas'], language: 'de' };
const days = [{ area: 'Deira', theme: 'Souks', activities: [] }, { area: 'Deira', theme: 'Creek', activities: [] }];

let env: Env;
let deps: Dependencies;
let upstream: string[];

beforeEach(() => {
  clearWeatherCache();
  vi.spyOn(console, 'log').mockImplementation(() => {});
  vi.spyOn(console, 'warn').mockImplementation(() => {});
  upstream = [];
  env = {
    OPENAI_API_KEY: 'sk-test-123',
    OPENWEATHER_API_KEY: 'ow-test-key',
    FIREBASE_PROJECT_NUMBER: '1085118524930',
    ALLOWED_APP_IDS: `${ANDROID}, ${IOS}`,
  };
  deps = {
    // "good-token" stands for a valid App Check token of the Android app.
    verifyToken: async (token, config) => (token === 'good-token' && config.allowedAppIds.includes(ANDROID) ? ANDROID : null),
    fetch: (async (url: string | URL) => {
      upstream.push(String(url));
      if (String(url).startsWith('https://api.openai.com/')) {
        return Response.json({ choices: [{ message: { content: JSON.stringify({ days }) }, finish_reason: 'stop' }] });
      }
      return Response.json({ list: [{ dt: 1, main: { temp: 30 }, weather: [{ icon: '01d' }], pop: 0 }] });
    }) as typeof fetch,
  };
});

function request(path: string, init: RequestInit & { token?: string | null } = {}) {
  const headers = new Headers(init.headers);
  const token = init.token === undefined ? 'good-token' : init.token;
  if (token) headers.set('X-Firebase-AppCheck', token);
  return handle(new Request(`https://api.example.workers.dev${path}`, { ...init, headers }), env, deps);
}

const planRequest = (body: unknown = form, init: RequestInit & { token?: string | null } = {}) =>
  request('/trip-plan', { method: 'POST', body: typeof body === 'string' ? body : JSON.stringify(body), ...init });

describe('POST /trip-plan', () => {
  it('answers with the days of the plan', async () => {
    const response = await planRequest();
    expect(response.status).toBe(200);
    expect(await response.json()).toEqual({ days });
    expect(upstream).toEqual(['https://api.openai.com/v1/chat/completions']);
  });

  it('refuses a request without an App Check token, without calling OpenAI', async () => {
    const response = await planRequest(form, { token: null });
    expect(response.status).toBe(401);
    expect(await response.json()).toEqual({ error: 'app_check_failed' });
    expect(upstream).toEqual([]);
  });

  it('refuses an invalid App Check token', async () => {
    expect((await planRequest(form, { token: 'forged' })).status).toBe(401);
    expect(upstream).toEqual([]);
  });

  it('refuses a form that the app would not send, without calling OpenAI', async () => {
    const response = await planRequest({ ...form, lengthInDays: 30 });
    expect(response.status).toBe(400);
    expect(await response.json()).toMatchObject({ error: 'invalid_request' });
    expect(upstream).toEqual([]);
  });

  it('refuses a body that is not JSON', async () => {
    expect((await planRequest('days=3')).status).toBe(400);
  });

  it('refuses a body that is far larger than the form', async () => {
    expect((await planRequest({ ...form, padding: 'x'.repeat(5000) })).status).toBe(413);
    expect(upstream).toEqual([]);
  });

  it('answers 503 while the OpenAI key is not set', async () => {
    delete env.OPENAI_API_KEY;
    const response = await planRequest();
    expect(response.status).toBe(503);
    expect(await response.json()).toEqual({ error: 'not_configured' });
  });

  it('limits the plans per IP address', async () => {
    const keys: string[] = [];
    env.PLAN_LIMITER = {
      limit: async ({ key }) => {
        keys.push(key);
        return { success: keys.length <= 1 };
      },
    };
    const headers = { 'CF-Connecting-IP': '203.0.113.7' };

    expect((await planRequest(form, { headers })).status).toBe(200);
    const second = await planRequest(form, { headers });
    expect(second.status).toBe(429);
    expect(await second.json()).toEqual({ error: 'too_many_requests' });
    expect(keys).toEqual(['203.0.113.7', '203.0.113.7']);
    expect(upstream).toHaveLength(1);
  });

  it('does not count requests without a valid App Check token against the limit', async () => {
    const limit = vi.fn(async () => ({ success: true }));
    env.PLAN_LIMITER = { limit };
    await planRequest(form, { token: null });
    expect(limit).not.toHaveBeenCalled();
  });

  it('logs the outcome without the key, the token or the form', async () => {
    const log = vi.spyOn(console, 'log');
    await planRequest();

    const line = String(log.mock.calls.at(-1)?.[0]);
    expect(JSON.parse(line)).toMatchObject({ method: 'POST', path: '/trip-plan', status: 200, app: 'android', days: 2, language: 'de' });
    for (const secret of ['sk-test-123', 'good-token', 'Deira', 'Spas']) expect(line).not.toContain(secret);
  });
});

describe('GET /weather', () => {
  it('answers with the forecast', async () => {
    const response = await request('/weather');
    expect(response.status).toBe(200);
    expect((await response.json()) as object).toHaveProperty('list');
  });

  it('refuses a request without an App Check token', async () => {
    expect((await request('/weather', { token: null })).status).toBe(401);
    expect(upstream).toEqual([]);
  });

  it('answers 503 while the OpenWeather key is not set', async () => {
    delete env.OPENWEATHER_API_KEY;
    expect((await request('/weather')).status).toBe(503);
  });
});

describe('other requests', () => {
  it('answers 404 for an unknown path and 405 for a wrong method', async () => {
    expect((await request('/')).status).toBe(404);
    expect((await request('/trip-plan')).status).toBe(405);
    expect((await request('/weather', { method: 'POST' })).status).toBe(405);
  });
});
