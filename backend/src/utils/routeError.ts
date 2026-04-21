import { Response } from 'express';

export function routeError(res: Response, err: any, status = 400): Response {
  return res.status(status).json({ error: err.message, details: err.details ?? err.hint ?? undefined });
}
