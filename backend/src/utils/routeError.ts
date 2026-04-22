import { Response } from 'express';

export function routeError(res: Response, err: unknown, status = 400): Response {
  const message = err instanceof Error ? err.message : String(err);
  const details = (err as Record<string, unknown>)?.details ?? (err as Record<string, unknown>)?.hint ?? undefined;
  return res.status(status).json({ error: message, ...(details !== undefined && { details }) });
}
