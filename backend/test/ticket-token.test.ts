import { randomBytes } from 'node:crypto';
import { describe, expect, it } from 'vitest';
import { open, seal } from '../src/lib/key-box.js';
import { generateEventKeyPair, signTicket, verifyTicket, type TicketClaims } from '../src/lib/ticket-token.js';

const claims: TicketClaims = {
  tid: '7b0c3f6e-2b0a-4c7e-9a43-0c7c1d7f9a10',
  eid: 'f1e2d3c4-b5a6-4978-8a9b-0c1d2e3f4a5b',
  name: 'Ayesha Khan',
  iat: 1_763_280_000,
};

describe('ticket tokens', () => {
  const keys = generateEventKeyPair();

  it('round-trips claims through sign and verify', () => {
    const token = signTicket(claims, keys.privateKeyPem);
    expect(token.startsWith('EP1.')).toBe(true);
    expect(verifyTicket(token, keys.publicKeyPem)).toEqual({ ok: true, claims });
  });

  it('produces the same token every time for the same ticket', () => {
    expect(signTicket(claims, keys.privateKeyPem)).toBe(signTicket(claims, keys.privateKeyPem));
  });

  it('rejects a token whose payload was edited', () => {
    const [prefix, , signature] = signTicket(claims, keys.privateKeyPem).split('.');
    const forged = Buffer.from(JSON.stringify({ ...claims, tid: 'someone-elses-ticket' })).toString('base64url');
    expect(verifyTicket(`${prefix}.${forged}.${signature}`, keys.publicKeyPem)).toEqual({
      ok: false,
      reason: 'bad_signature',
    });
  });

  it("rejects a token signed with another event's key", () => {
    const other = generateEventKeyPair();
    const token = signTicket(claims, other.privateKeyPem);
    expect(verifyTicket(token, keys.publicKeyPem)).toMatchObject({ ok: false, reason: 'bad_signature' });
  });

  it.each(['', 'hello', 'EP1.abc', 'XX1.abc.def', 'EP1.a.b.c'])('rejects malformed input %j', (token) => {
    expect(verifyTicket(token, keys.publicKeyPem)).toMatchObject({ ok: false, reason: 'malformed' });
  });
});

describe('key box', () => {
  const key = randomBytes(32);

  it('decrypts what it encrypted', () => {
    expect(open(seal('secret signing key', key), key)).toBe('secret signing key');
  });

  it('uses a fresh IV for every seal', () => {
    expect(seal('same text', key)).not.toBe(seal('same text', key));
  });

  it('fails loudly with the wrong key', () => {
    expect(() => open(seal('secret', key), randomBytes(32))).toThrow();
  });
});
