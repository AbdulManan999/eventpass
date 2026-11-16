import { createPrivateKey, createPublicKey, generateKeyPairSync, sign, verify } from 'node:crypto';

// A ticket token is what the attendee's QR code contains:
//
//   EP1.<base64url(JSON payload)>.<base64url(Ed25519 signature)>
//
// Scanner devices hold the event's public key, so they can check a ticket
// with no network connection. Ed25519 signatures are deterministic, so the
// same ticket always produces the same token.

const PREFIX = 'EP1';

export interface TicketClaims {
  /** ticket id */
  tid: string;
  /** event id */
  eid: string;
  /** holder's display name, shown on the scanner screen */
  name: string;
  /** issued at, unix seconds */
  iat: number;
}

export type VerifyResult = { ok: true; claims: TicketClaims } | { ok: false; reason: 'malformed' | 'bad_signature' };

export function generateEventKeyPair(): { publicKeyPem: string; privateKeyPem: string } {
  const { publicKey, privateKey } = generateKeyPairSync('ed25519');
  return {
    publicKeyPem: publicKey.export({ type: 'spki', format: 'pem' }).toString(),
    privateKeyPem: privateKey.export({ type: 'pkcs8', format: 'pem' }).toString(),
  };
}

export function signTicket(claims: TicketClaims, privateKeyPem: string): string {
  const payload = Buffer.from(JSON.stringify(claims)).toString('base64url');
  const signature = sign(null, Buffer.from(`${PREFIX}.${payload}`), createPrivateKey(privateKeyPem));
  return `${PREFIX}.${payload}.${signature.toString('base64url')}`;
}

export function verifyTicket(token: string, publicKeyPem: string): VerifyResult {
  const parts = token.split('.');
  if (parts.length !== 3 || parts[0] !== PREFIX) return { ok: false, reason: 'malformed' };
  const [, payload, signature] = parts as [string, string, string];

  const valid = verify(
    null,
    Buffer.from(`${PREFIX}.${payload}`),
    createPublicKey(publicKeyPem),
    Buffer.from(signature, 'base64url'),
  );
  if (!valid) return { ok: false, reason: 'bad_signature' };

  try {
    const claims = JSON.parse(Buffer.from(payload, 'base64url').toString('utf8')) as TicketClaims;
    if (typeof claims.tid !== 'string' || typeof claims.eid !== 'string') return { ok: false, reason: 'malformed' };
    return { ok: true, claims };
  } catch {
    return { ok: false, reason: 'malformed' };
  }
}
