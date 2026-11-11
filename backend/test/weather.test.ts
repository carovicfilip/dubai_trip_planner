import { beforeEach, describe, expect, it } from 'vitest';

import { clearWeatherCache, dubaiForecast, WEATHER_CACHE_MS, WEATHER_STALE_MS } from '../src/weather';

const slot = {
  dt: 1793404800,
  main: { temp: 31.2, feels_like: 33, pressure: 1010, humidity: 40 },
  weather: [{ id: 800, main: 'Clear', description: 'clear sky', icon: '01d' }],
  wind: { speed: 3.1 },
  pop: 0.2,
  dt_txt: '2026-10-30 12:00:00',
};
const openWeatherBody = { cod: '200', cnt: 1, list: [slot], city: { name: 'Dubai' } };

let now: number;
let requests: URL[];
let respond: () => Response;

const fetchFn = (async (url: URL) => {
  requests.push(url);
  return respond();
}) as unknown as typeof fetch;

const forecast = () => dubaiForecast('ow-test-key', fetchFn, () => now);

beforeEach(() => {
  clearWeatherCache();
  now = Date.UTC(2026, 9, 30, 12);
  requests = [];
  respond = () => Response.json(openWeatherBody);
});

describe('dubaiForecast', () => {
  it('asks OpenWeather for the Dubai forecast in metric units', async () => {
    await forecast();

    const [url] = requests as [URL];
    expect(url.origin + url.pathname).toBe('https://api.openweathermap.org/data/2.5/forecast');
    expect(url.searchParams.get('lat')).toBe('25.276987');
    expect(url.searchParams.get('lon')).toBe('55.296249');
    expect(url.searchParams.get('units')).toBe('metric');
    expect(url.searchParams.get('appid')).toBe('ow-test-key');
  });

  it('keeps only what the app reads, in OpenWeather\'s shape', async () => {
    const outcome = await forecast();
    expect(outcome.status).toBe(200);
    expect(JSON.parse(outcome.body)).toEqual({ list: [{ dt: 1793404800, main: { temp: 31.2 }, weather: [{ icon: '01d' }], pop: 0.2 }] });
  });

  it('serves one forecast to everyone for 30 minutes', async () => {
    await forecast();
    now += WEATHER_CACHE_MS - 1;
    await forecast();
    expect(requests).toHaveLength(1);

    now += 1;
    await forecast();
    expect(requests).toHaveLength(2);
  });

  it('requests made while one is running share it', async () => {
    await Promise.all([forecast(), forecast(), forecast()]);
    expect(requests).toHaveLength(1);
  });

  it('serves the last forecast when OpenWeather fails, for up to 6 hours', async () => {
    const first = await forecast();
    respond = () => new Response('{"cod":429,"message":"Too many requests"}', { status: 429 });

    now += WEATHER_STALE_MS - 1;
    const stale = await forecast();
    expect(stale.status).toBe(200);
    expect(stale.body).toBe(first.body);

    now += 1;
    expect((await forecast()).status).toBe(502);
  });

  it('fails without a forecast to fall back on, and never repeats OpenWeather\'s answer', async () => {
    respond = () => new Response('{"cod":401,"message":"Invalid API key. Please see https://openweathermap.org/faq"}', { status: 401 });
    const outcome = await forecast();

    expect(outcome.status).toBe(502);
    expect(JSON.parse(outcome.body)).toEqual({ error: 'upstream_error' });
    expect(JSON.stringify(outcome)).not.toContain('ow-test-key');
  });
});
