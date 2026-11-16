import type { FastifyInstance, FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';

export class HttpError extends Error {
  constructor(
    readonly statusCode: number,
    readonly code: string,
    message: string,
    /** Extra fields merged into the JSON error body, e.g. { distanceM }. */
    readonly details: Record<string, unknown> = {},
  ) {
    super(message);
  }
}

export const notFound = (what: string) => new HttpError(404, 'not_found', `${what} not found`);
export const forbidden = (message = 'You do not have access to this resource') => new HttpError(403, 'forbidden', message);
export const conflict = (code: string, message: string) => new HttpError(409, code, message);

export function registerErrorHandler(app: FastifyInstance): void {
  app.setErrorHandler((err: unknown, request: FastifyRequest, reply: FastifyReply) => {
    if (err instanceof ZodError) {
      return reply.status(400).send({
        error: 'validation_failed',
        message: 'Request is invalid',
        issues: err.issues.map((i) => ({ path: i.path.join('.'), message: i.message })),
      });
    }
    if (err instanceof HttpError) {
      return reply.status(err.statusCode).send({ error: err.code, message: err.message, ...err.details });
    }
    const status = (err as { statusCode?: number }).statusCode;
    if (status && status < 500) {
      return reply.status(status).send({ error: 'bad_request', message: (err as Error).message });
    }
    request.log.error(err);
    return reply.status(500).send({ error: 'internal', message: 'Something went wrong' });
  });
}
