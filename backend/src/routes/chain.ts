import { Router, Response } from 'express';
import { z } from 'zod';
import { authenticate, AuthRequest } from '../middleware/auth.js';
import { getRoomByCode, getPlayerListForRoom } from '../services/roomService.js';
import { addChainSegment, getChainSegments, getLastSegment, getNextPlayer } from '../services/chainService.js';
import { routeError } from '../utils/routeError.js';

const router = Router({ mergeParams: true });

const submitSchema = z.object({
  segmentType: z.enum(['sentence', 'blank_fill']),
  content: z.string().min(1).max(500),
});

// Get all chain segments (revealed after game ends)
router.get('/', authenticate, async (req: AuthRequest, res: Response) => {
  try {
    const room = await getRoomByCode(req.params.code);
    const segments = await getChainSegments(room.id);
    return res.json(segments);
  } catch (err: any) {
    return routeError(res, err);
  }
});

// Get current turn info
router.get('/turn', authenticate, async (req: AuthRequest, res: Response) => {
  try {
    const room = await getRoomByCode(req.params.code);
    const last = await getLastSegment(room.id);
    const playerIds = await getPlayerListForRoom(room.id);
    const nextPlayerId = getNextPlayer(playerIds, last?.author_id ?? null, last?.round_number ?? 0);
    const nextType = last?.segment_type === 'sentence' ? 'blank_fill' : 'sentence';

    return res.json({
      currentPlayerId: nextPlayerId,
      segmentType: nextType,
      roundNumber: (last?.round_number ?? 0) + 1,
      isYourTurn: nextPlayerId === req.user!.id,
      previousContent: last?.segment_type === 'sentence' ? last.content : undefined,
    });
  } catch (err: any) {
    return routeError(res, err);
  }
});

// Submit a chain segment
router.post('/submit', authenticate, async (req: AuthRequest, res: Response) => {
  const parsed = submitSchema.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });

  try {
    const room = await getRoomByCode(req.params.code);

    // Verify it's the requester's turn
    const last = await getLastSegment(room.id);
    const playerIds = await getPlayerListForRoom(room.id);
    const expected = getNextPlayer(playerIds, last?.author_id ?? null, last?.round_number ?? 0);

    if (expected !== req.user!.id) {
      return res.status(403).json({ error: 'Not your turn' });
    }

    const segment = await addChainSegment(
      room.id,
      req.user!.id,
      parsed.data.segmentType,
      parsed.data.content
    );

    return res.status(201).json(segment);
  } catch (err: any) {
    return routeError(res, err);
  }
});

export default router;
