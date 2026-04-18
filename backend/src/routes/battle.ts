import { Router, Response } from 'express';
import { z } from 'zod';
import { authenticate, AuthRequest } from '../middleware/auth.js';
import { getRoomByCode } from '../services/roomService.js';
import {
  submitBattleEntry,
  castVote,
  getResults,
  allPlayersSubmitted,
} from '../services/battleService.js';
import { createStory, fillBlank } from '../services/storyService.js';
import { supabase } from '../config/supabase.js';

const router = Router({ mergeParams: true });

const submitSchema = z.object({
  filledBlanks: z.array(z.object({ position: z.number().int().min(0), adjective: z.string().min(1).max(50) })),
  continuation: z.string().min(1).max(1000),
  templateStoryId: z.string().uuid(),
});

const voteSchema = z.object({ entryId: z.string().uuid() });

// Get battle prompt (master's template story)
router.get('/prompt', authenticate, async (req: AuthRequest, res: Response) => {
  try {
    const room = await getRoomByCode(req.params.code);
    const { data, error } = await supabase
      .from('stories')
      .select('id, content, story_blanks(position)')
      .eq('room_id', room.id)
      .order('created_at')
      .limit(1)
      .single();

    if (error) return res.status(404).json({ error: 'No prompt created yet' });
    return res.json(data);
  } catch (err: any) {
    return res.status(400).json({ error: err.message });
  }
});

// Submit battle entry (fill blanks + continuation)
router.post('/submit', authenticate, async (req: AuthRequest, res: Response) => {
  const parsed = submitSchema.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });

  try {
    const room = await getRoomByCode(req.params.code);

    // Create a personal copy of the story for this player
    const { data: template } = await supabase
      .from('stories')
      .select('content')
      .eq('id', parsed.data.templateStoryId)
      .single();

    if (!template) throw new Error('Template story not found');

    const playerStory = await createStory(room.id, template.content, req.user!.id);

    for (const blank of parsed.data.filledBlanks) {
      await fillBlank(playerStory.id, blank.position, blank.adjective, req.user!.id);
    }

    const entry = await submitBattleEntry(
      room.id,
      req.user!.id,
      playerStory.id,
      parsed.data.continuation
    );

    // Check if all players submitted — if so, mark room finished
    const done = await allPlayersSubmitted(room.id);
    if (done) {
      await supabase
        .from('rooms')
        .update({ status: 'in_progress' }) // stays in_progress until voting is done
        .eq('id', room.id);
    }

    return res.status(201).json({ entry, allSubmitted: done });
  } catch (err: any) {
    return res.status(400).json({ error: err.message });
  }
});

// Cast vote
router.post('/vote', authenticate, async (req: AuthRequest, res: Response) => {
  const parsed = voteSchema.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });

  try {
    const room = await getRoomByCode(req.params.code);
    await castVote(room.id, req.user!.id, parsed.data.entryId);
    return res.json({ success: true });
  } catch (err: any) {
    return res.status(400).json({ error: err.message });
  }
});

// Get results
router.get('/results', authenticate, async (req: AuthRequest, res: Response) => {
  try {
    const room = await getRoomByCode(req.params.code);
    const results = await getResults(room.id);
    return res.json(results);
  } catch (err: any) {
    return res.status(400).json({ error: err.message });
  }
});

export default router;
