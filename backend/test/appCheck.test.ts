import { createLocalJWKSet, exportJWK, generateKeyPair, SignJWT } from 'jose';
import { beforeAll, describe, expect, it } from 'vitest';

import { verifyAppCheckToken, type AppCheckConfig } from '../src/appCheck';

const PROJECT_NUMBER = '1085118524930';
const ANDROID = '1:1085118524930:android:03876253e309dc1daf011b';
const IOS = '1:1085118524930:ios:a8022d8e2cb93f65af011b';

let config: AppCheckConfig;
let firebaseKey: CryptoKey;
let otherKey: CryptoKey;

beforeAll(async () => {
  const firebase = await generateKeyPair('RS256');
  const other = await generateKeyPair('RS256');
  firebaseKey = firebase.privateKey;
  otherKey = other.privateKey;
  const jwk = { ...(await exportJWK(firebase.publicKey)), kid: 'firebase-key', alg: 'RS256' };
  config = { projectNumber: PROJECT_NUMBER, allowedAppIds: [ANDROID, IOS], keys: createLocalJWKSet({ keys: [jwk] }) };
});

/** A token shaped like the ones App Check issues, with any part changed. */
function token(changes: { sub?: string; iss?: string; aud?: string[]; exp?: number; typ?: string; key?: CryptoKey } = {}) {
  const now = Math.floor(Date.now() / 1000);
  return new SignJWT({})
    .setProtectedHeader({ alg: 'RS256', typ: changes.typ ?? 'JWT', kid: 'firebase-key' })
    .setSubject(changes.sub ?? ANDROID)
    .setIssuer(changes.iss ?? `https://firebaseappcheck.googleapis.com/${PROJECT_NUMBER}`)
    .setAudience(changes.aud ?? [`projects/${PROJECT_NUMBER}`, 'projects/dubaitripplanner-ae015'])
    .setIssuedAt(now - 60)
    .setExpirationTime(changes.exp ?? now + 3600)
    .sign(changes.key ?? firebaseKey);
}

describe('verifyAppCheckToken', () => {
  it('accepts a token of this project and returns the app it was made for', async () => {
    expect(await verifyAppCheckToken(await token(), config)).toBe(ANDROID);
    expect(await verifyAppCheckToken(await token({ sub: IOS }), config)).toBe(IOS);
  });

  it('rejects a missing token', async () => {
    expect(await verifyAppCheckToken(null, config)).toBeNull();
    expect(await verifyAppCheckToken('', config)).toBeNull();
  });

  it('rejects text that is not a token', async () => {
    expect(await verifyAppCheckToken('not-a-token', config)).toBeNull();
  });

  it('rejects a token signed with another key', async () => {
    expect(await verifyAppCheckToken(await token({ key: otherKey }), config)).toBeNull();
  });

  it('rejects an expired token', async () => {
    expect(await verifyAppCheckToken(await token({ exp: Math.floor(Date.now() / 1000) - 600 }), config)).toBeNull();
  });

  it('rejects a token of another Firebase project', async () => {
    expect(await verifyAppCheckToken(await token({ iss: 'https://firebaseappcheck.googleapis.com/999' }), config)).toBeNull();
    expect(await verifyAppCheckToken(await token({ aud: ['projects/999'] }), config)).toBeNull();
  });

  it('rejects a token issued by something other than App Check', async () => {
    expect(await verifyAppCheckToken(await token({ iss: `https://securetoken.google.com/${PROJECT_NUMBER}` }), config)).toBeNull();
  });

  it('rejects a token made for another app of the same project', async () => {
    expect(await verifyAppCheckToken(await token({ sub: '1:1085118524930:web:0000' }), config)).toBeNull();
  });

  it('rejects a token whose header is not of type JWT', async () => {
    expect(await verifyAppCheckToken(await token({ typ: 'at+jwt' }), config)).toBeNull();
  });

  it('rejects an unsigned token', async () => {
    const [, payload] = (await token()).split('.');
    const header = Buffer.from(JSON.stringify({ alg: 'none', typ: 'JWT' })).toString('base64url');
    expect(await verifyAppCheckToken(`${header}.${payload}.`, config)).toBeNull();
  });
});
