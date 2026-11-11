// The Dubai forecast for the Explore tab. Every user sees the same forecast,
// so the Worker loads it once and shares it with everyone it serves.

const DUBAI = { lat: 25.276987, lon: 55.296249 };
// OpenWeather's free forecast comes in 3-hour steps, so 30 minutes is fresh
// enough, and keeps far below its rate limit however many people use the app.
export const WEATHER_CACHE_MS = 30 * 60 * 1000;
// When OpenWeather fails, an older forecast is better than none.
export const WEATHER_STALE_MS = 6 * 60 * 60 * 1000;
const OPENWEATHER_TIMEOUT_MS = 15_000;

interface CachedForecast {
  loadedAt: number;
  body: string;
}

// Per Worker instance. Each Cloudflare location runs its own instances, so
// OpenWeather is asked about once per 30 minutes per busy location.
let cached: CachedForecast | undefined;
let inFlight: Promise<string> | undefined;

export function clearWeatherCache(): void {
  cached = undefined;
  inFlight = undefined;
}

export interface WeatherOutcome {
  status: number;
  body: string;
  log: Record<string, unknown>;
}

export async function dubaiForecast(
  apiKey: string,
  fetchFn: typeof fetch = fetch,
  now: () => number = Date.now,
): Promise<WeatherOutcome> {
  if (cached && now() - cached.loadedAt < WEATHER_CACHE_MS) {
    return { status: 200, body: cached.body, log: { cache: 'hit' } };
  }
  try {
    // Requests that arrive while one is running share it.
    const body = await (inFlight ??= loadForecast(apiKey, fetchFn).finally(() => (inFlight = undefined)));
    cached = { loadedAt: now(), body };
    return { status: 200, body, log: { cache: 'miss' } };
  } catch (error) {
    const reason = error instanceof Error ? error.message : 'unknown';
    if (cached && now() - cached.loadedAt < WEATHER_STALE_MS) {
      return { status: 200, body: cached.body, log: { cache: 'stale', reason } };
    }
    return { status: 502, body: JSON.stringify({ error: 'upstream_error' }), log: { reason } };
  }
}

async function loadForecast(apiKey: string, fetchFn: typeof fetch): Promise<string> {
  const url = new URL('https://api.openweathermap.org/data/2.5/forecast');
  url.searchParams.set('lat', String(DUBAI.lat));
  url.searchParams.set('lon', String(DUBAI.lon));
  url.searchParams.set('units', 'metric');
  url.searchParams.set('appid', apiKey);

  const response = await fetchFn(url, { signal: AbortSignal.timeout(OPENWEATHER_TIMEOUT_MS) });
  // The status only: OpenWeather's error body can repeat the request URL,
  // and with it the key.
  if (response.status !== 200) throw new Error(`OpenWeather answered ${response.status}`);
  const data = (await response.json()) as { list?: unknown };
  if (!Array.isArray(data.list)) throw new Error('OpenWeather answer has no list');
  return JSON.stringify({ list: data.list.map(slimSlot) });
}

/**
 * One 3-hour slot with only what the app reads: the time, the temperature,
 * the icon and the chance of rain, in OpenWeather's own shape.
 */
function slimSlot(slot: unknown): unknown {
  const { dt, main, weather, pop } = (slot ?? {}) as {
    dt?: unknown;
    main?: { temp?: unknown };
    weather?: { icon?: unknown }[];
    pop?: unknown;
  };
  return { dt, main: { temp: main?.temp }, weather: [{ icon: weather?.[0]?.icon }], pop: pop ?? 0 };
}
