import Fastify, { type FastifyServerOptions } from 'fastify';
import cors from '@fastify/cors';
import jwt from '@fastify/jwt';
import { authRoutes } from './auth.js';
import type { Config } from './config.js';
import type { Db } from './db.js';
import { eventRoutes } from './events.js';
import { registerErrorHandler } from './http.js';
import { scanRoutes } from './scans.js';
import { ticketRoutes } from './tickets.js';

export async function buildApp(config: Config, db: Db, options: FastifyServerOptions = {}) {
  const app = Fastify(options);
  const keyEncryptionKey = Buffer.from(config.KEY_ENCRYPTION_KEY, 'base64');

  registerErrorHandler(app);
  await app.register(cors, { origin: config.CORS_ORIGIN === '*' ? true : config.CORS_ORIGIN.split(',') });
  await app.register(jwt, { secret: config.JWT_SECRET });

  app.get('/health', async () => {
    await db.query('SELECT 1');
    return { status: 'ok' };
  });

  await app.register(authRoutes, { db });
  await app.register(eventRoutes, { db, keyEncryptionKey });
  await app.register(ticketRoutes, { db, keyEncryptionKey });
  await app.register(scanRoutes, { db });

  return app;
}
