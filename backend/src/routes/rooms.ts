import { Router, Response } from 'express';
import { z } from 'zod';
import { authenticate, AuthRequest } from '../middleware/auth.js';
import { createRoom, getRoomByCode, joinRoom, leaveRoom, startGame } from '../services/roomService.js';
import { routeError } from '../utils/routeError.js';
import { emitToRoom } from '../services/socketService.js';

const router = Router();

const createRoomSchema = z.object({
  mode: z.enum(['fill_reveal', 'rotating_chain', 'battle']),
  maxPlayers: z.number().int().min(1).max(10).default(6),
});

router.post('/', authenticate, async (req: AuthRequest, res: Response) => {
  const parsed = createRoomSchema.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });

  try {
    const room = await createRoom(req.user!.id, parsed.data.mode, parsed.data.maxPlayers);
    return res.status(201).json(room);
  } catch (err) {
    console.error('[POST /api/rooms]', err);
    return routeError(res, err, 500);
  }
});

router.get('/:code', authenticate, async (req: AuthRequest, res: Response) => {
  try {
    const room = await getRoomByCode(req.params.code);
    return res.json(room);
  } catch {
    return res.status(404).json({ error: 'Room not found' });
  }
});

router.post('/:code/join', authenticate, async (req: AuthRequest, res: Response) => {
  try {
    const room = await joinRoom(req.params.code, req.user!.id);
    return res.json(room);
  } catch (err) {
    console.error('[POST /api/rooms/:code/join]', err);
    return routeError(res, err);
  }
});

router.post('/:code/leave', authenticate, async (req: AuthRequest, res: Response) => {
  try {
    const room = await getRoomByCode(req.params.code);
    await leaveRoom(room.id, req.user!.id);
    return res.json({ success: true });
  } catch (err) {
    console.error('[POST /api/rooms/:code/leave]', err);
    return routeError(res, err);
  }
});

router.post('/:code/start', authenticate, async (req: AuthRequest, res: Response) => {
  try {
    const room = await getRoomByCode(req.params.code);
    const updated = await startGame(room.id, req.user!.id);
    emitToRoom(req.io, req.params.code, 'room:game_started', updated);
    return res.json(updated);
  } catch (err) {
    console.error('[POST /api/rooms/:code/start]', err);
    return routeError(res, err);
  }
});

export default router;
