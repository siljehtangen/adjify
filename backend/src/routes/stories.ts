import { Router, Response } from 'express';
import { z } from 'zod';
import { authenticate, AuthRequest } from '../middleware/auth.js';
import { getRoomByCode } from '../services/roomService.js';
import { countBlanks, createStory, fillBlank, getStoryWithBlanks } from '../services/storyService.js';
import { supabase } from '../config/supabase.js';

const router = Router({ mergeParams: true });

const createStorySchema = z.object({ content: z.string().min(10) });
const fillBlankSchema = z.object({
  position: z.number().int().min(0),
  adjective: z.string().min(1).max(50),
});

// Create story for room (fill_reveal + battle modes)
router.post('/', authenticate, async (req: AuthRequest, res: Response) => {
  const parsed = createStorySchema.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });

  try {
    const room = await getRoomByCode(req.params.code);

    if (room.mode === 'fill_reveal') {
      const playerCount = room.room_players.length;
      const otherPlayers = playerCount - 1;
      const minBlanks = otherPlayers > 0 ? otherPlayers : 1;
      const blankCount = countBlanks(parsed.data.content);
      if (blankCount < minBlanks) {
        return res.status(400).json({
          error: `Story must have at least ${minBlanks} [ADJ] blank${minBlanks !== 1 ? 's' : ''} — one per player`,
        });
      }
    }

    const story = await createStory(room.id, parsed.data.content, req.user!.id);
    return res.status(201).json(story);
  } catch (err: any) {
    return res.status(400).json({ error: err.message });
  }
});

// Get story with blanks for room
router.get('/', authenticate, async (req: AuthRequest, res: Response) => {
  try {
    const room = await getRoomByCode(req.params.code);
    const { data, error } = await supabase
      .from('stories')
      .select('*, story_blanks(*)')
      .eq('room_id', room.id)
      .order('position', { referencedTable: 'story_blanks' });

    if (error) throw error;
    return res.json(data);
  } catch (err: any) {
    return res.status(400).json({ error: err.message });
  }
});

// Fill a blank
router.post('/:storyId/blanks', authenticate, async (req: AuthRequest, res: Response) => {
  const parsed = fillBlankSchema.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });

  try {
    const story = await getStoryWithBlanks(req.params.storyId);
    if (story.created_by === req.user!.id) {
      return res.status(403).json({ error: 'The story writer cannot fill their own blanks' });
    }
    const result = await fillBlank(
      req.params.storyId,
      parsed.data.position,
      parsed.data.adjective,
      req.user!.id
    );
    return res.json(result);
  } catch (err: any) {
    return res.status(400).json({ error: err.message });
  }
});

// Get fully rendered story (only when complete)
router.get('/:storyId/reveal', authenticate, async (req: AuthRequest, res: Response) => {
  try {
    const story = await getStoryWithBlanks(req.params.storyId);
    const incomplete = story.story_blanks.some((b: { filled_by: string | null }) => !b.filled_by);
    if (incomplete) {
      return res.status(403).json({ error: 'Story is not fully filled yet' });
    }
    return res.json(story);
  } catch (err: any) {
    return res.status(400).json({ error: err.message });
  }
});

export default router;
