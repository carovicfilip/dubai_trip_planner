import { createRemoteJWKSet, jwtVerify, type JWTVerifyGetKey } from 'jose';

// Public keys that Firebase signs App Check tokens with. They rotate, and
// Firebase recommends caching them for up to 6 hours.
const JWKS_URL = new URL('https://firebaseappcheck.googleapis.com/v1/jwks');
const KEYS_CACHE_MS = 6 * 60 * 60 * 1000;

let firebaseKeys: JWTVerifyGetKey | undefined;

export interface AppCheckConfig {
  // The Firebase project number, which is the token's issuer and audience.
  projectNumber: string;
  // The Firebase app ids of this app (Android and iOS).
  allowedAppIds: readonly string[];
  // Keys to check the signature with. Tests pass their own; by default
  // they are loaded from Firebase.
  keys?: JWTVerifyGetKey;
}

/**
 * Checks an App Check token the way Firebase describes for a custom backend:
 * an RS256 JWT signed by Firebase, issued by App Check for this project,
 * not expired, and made for one of this app's ids.
 *
 * Returns the app id the token was made for, or null when the token is
 * missing or not valid.
 */
export async function verifyAppCheckToken(token: string | null, config: AppCheckConfig): Promise<string | null> {
  if (!token) return null;
  const keys = config.keys ?? (firebaseKeys ??= createRemoteJWKSet(JWKS_URL, { cacheMaxAge: KEYS_CACHE_MS }));
  try {
    const { payload } = await jwtVerify(token, keys, {
      algorithms: ['RS256'],
      typ: 'JWT',
      issuer: `https://firebaseappcheck.googleapis.com/${config.projectNumber}`,
      audience: `projects/${config.projectNumber}`,
    });
    const appId = payload.sub;
    return appId && config.allowedAppIds.includes(appId) ? appId : null;
  } catch (error) {
    console.warn(JSON.stringify({ event: 'app_check_rejected', reason: errorName(error) }));
    return null;
  }
}

function errorName(error: unknown): string {
  if (error && typeof error === 'object' && 'code' in error) return String(error.code);
  return error instanceof Error ? error.name : 'unknown';
}
