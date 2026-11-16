import type { FastifyInstance, FastifyRequest } from 'fastify';
import bcrypt from 'bcryptjs';
import { z } from 'zod';
import type { Db } from './db.js';
import { conflict, forbidden, HttpError } from './http.js';

export type Role = 'attendee' | 'organizer';

export interface AuthUser {
  sub: string;
  role: Role;
}

declare module '@fastify/jwt' {
  interface FastifyJWT {
    payload: AuthUser;
    user: AuthUser;
  }
}

/** preHandler: rejects the request with 401 unless it carries a valid bearer token. */
export async function authenticate(request: FastifyRequest): Promise<void> {
  try {
    await request.jwtVerify();
  } catch {
    throw new HttpError(401, 'unauthorized', 'Missing or invalid access token');
  }
}

export function requireRole(role: Role) {
  return async (request: FastifyRequest) => {
    await authenticate(request);
    if (request.user.role !== role) throw forbidden(`Only ${role}s can do this`);
  };
}

const registerBody = z.object({
  email: z.string().email().transform((e) => e.toLowerCase()),
  password: z.string().min(8).max(128),
  name: z.string().trim().min(1).max(100),
  role: z.enum(['attendee', 'organizer']).default('attendee'),
});

const loginBody = z.object({
  email: z.string().email().transform((e) => e.toLowerCase()),
  password: z.string(),
});

interface UserRow {
  id: string;
  email: string;
  name: string;
  role: Role;
  password_hash: string;
}

const publicUser = (u: UserRow) => ({ id: u.id, email: u.email, name: u.name, role: u.role });

export async function authRoutes(app: FastifyInstance, { db }: { db: Db }): Promise<void> {
  const issueToken = (u: UserRow) => app.jwt.sign({ sub: u.id, role: u.role }, { expiresIn: '7d' });

  app.post('/auth/register', async (request, reply) => {
    const body = registerBody.parse(request.body);
    const passwordHash = await bcrypt.hash(body.password, 10);
    const { rows } = await db.query<UserRow>(
      `INSERT INTO users (email, password_hash, name, role) VALUES ($1, $2, $3, $4)
       ON CONFLICT (email) DO NOTHING
       RETURNING id, email, name, role, password_hash`,
      [body.email, passwordHash, body.name, body.role],
    );
    const user = rows[0];
    if (!user) throw conflict('email_taken', 'An account with this email already exists');
    return reply.status(201).send({ token: issueToken(user), user: publicUser(user) });
  });

  app.post('/auth/login', async (request) => {
    const body = loginBody.parse(request.body);
    const { rows } = await db.query<UserRow>(
      'SELECT id, email, name, role, password_hash FROM users WHERE email = $1',
      [body.email],
    );
    const user = rows[0];
    if (!user || !(await bcrypt.compare(body.password, user.password_hash))) {
      throw new HttpError(401, 'invalid_credentials', 'Email or password is incorrect');
    }
    return { token: issueToken(user), user: publicUser(user) };
  });

  app.get('/me', { preHandler: authenticate }, async (request) => {
    const { rows } = await db.query<UserRow>(
      'SELECT id, email, name, role, password_hash FROM users WHERE id = $1',
      [request.user.sub],
    );
    if (!rows[0]) throw new HttpError(401, 'unauthorized', 'Account no longer exists');
    return publicUser(rows[0]);
  });
}
