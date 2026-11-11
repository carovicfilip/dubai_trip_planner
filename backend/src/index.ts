// The app's backend: the only place that holds the OpenAI and OpenWeather
// keys. Every request must carry a Firebase App Check token, which proves it
// comes from the real app on a real device.
//
//   POST /trip-plan  the trip form as JSON  ->  { "days": [...] }
//   GET  /weather                           ->  { "list": [...] }  (OpenWeather's shape)
//
// Errors are JSON too: { "error": "<code>" }.

import { verifyAppCheckToken, type AppCheckConfig } from './appCheck';
import { parseTripRequest, planTrip } from './tripPlan';
import { dubaiForecast } from './weather';

export interface Env {
  // Secrets, set with `npx wrangler secret put <NAME>`.
  OPENAI_API_KEY?: string;
  OPENWEATHER_API_KEY?: string;
  // Plain values from wrangler.jsonc.
  FIREBASE_PROJECT_NUMBER: string;
  ALLOWED_APP_IDS: string;
  PLAN_LIMITER?: { limit(options: { key: string }): Promise<{ success: boolean }> };
}

export interface Dependencies {
  verifyToken: (token: string | null, config: AppCheckConfig) => Promise<string | null>;
  fetch: typeof fetch;
}

const defaultDependencies: Dependencies = { verifyToken: verifyAppCheckToken, fetch: (input, init) => fetch(input, init) };

// The trip form is a few hundred bytes; anything much larger is not from the app.
const MAX_BODY_BYTES = 4096;

export default {
  fetch: (request: Request, env: Env) => handle(request, env),
} satisfies ExportedHandler<Env>;

export async function handle(request: Request, env: Env, deps: Dependencies = defaultDependencies): Promise<Response> {
  const started = Date.now();
  const { pathname } = new URL(request.url);
  const log: Record<string, unknown> = { method: request.method, path: pathname };

  const response = await route(request, env, deps, log);

  log.status = response.status;
  log.ms = Date.now() - started;
  console.log(JSON.stringify(log));
  return response;
}

async function route(request: Request, env: Env, deps: Dependencies, log: Record<string, unknown>): Promise<Response> {
  const { pathname } = new URL(request.url);
  const expectedMethod = { '/trip-plan': 'POST', '/weather': 'GET' }[pathname];
  if (!expectedMethod) return error(404, 'not_found');
  if (request.method !== expectedMethod) return error(405, 'method_not_allowed');

  const appId = await deps.verifyToken(request.headers.get('X-Firebase-AppCheck'), {
    projectNumber: env.FIREBASE_PROJECT_NUMBER,
    allowedAppIds: env.ALLOWED_APP_IDS.split(',').map((id) => id.trim()),
  });
  if (!appId) return error(401, 'app_check_failed');
  log.app = appId.includes(':ios:') ? 'ios' : 'android';

  if (pathname === '/weather') {
    if (!env.OPENWEATHER_API_KEY) return error(503, 'not_configured');
    const outcome = await dubaiForecast(env.OPENWEATHER_API_KEY, deps.fetch);
    Object.assign(log, outcome.log);
    return new Response(outcome.body, { status: outcome.status, headers: { 'Content-Type': 'application/json' } });
  }

  if (env.PLAN_LIMITER) {
    const ip = request.headers.get('CF-Connecting-IP') ?? 'unknown';
    const { success } = await env.PLAN_LIMITER.limit({ key: ip });
    if (!success) return error(429, 'too_many_requests');
  }

  const text = await request.text();
  if (new TextEncoder().encode(text).length > MAX_BODY_BYTES) return error(413, 'body_too_large');
  let json: unknown;
  try {
    json = JSON.parse(text);
  } catch {
    return error(400, 'invalid_request', 'body is not JSON');
  }
  const trip = parseTripRequest(json);
  if ('invalid' in trip) return error(400, 'invalid_request', trip.invalid);
  log.days = trip.lengthInDays;
  log.language = trip.language;

  if (!env.OPENAI_API_KEY) return error(503, 'not_configured');
  const outcome = await planTrip(trip, env.OPENAI_API_KEY, deps.fetch);
  Object.assign(log, outcome.log);
  return Response.json(outcome.body, { status: outcome.status });
}

function error(status: number, code: string, detail?: string): Response {
  return Response.json(detail ? { error: code, detail } : { error: code }, { status });
}
