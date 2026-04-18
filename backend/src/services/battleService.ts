import { supabase } from '../config/supabase.js';
import { BattleEntry } from '../types/index.js';

export async function getOrCreateEntry(roomId: string, playerId: string): Promise<BattleEntry> {
  const { data: existing } = await supabase
    .from('battle_entries')
    .select('*')
    .eq('room_id', roomId)
    .eq('player_id', playerId)
    .maybeSingle();

  if (existing) return existing as BattleEntry;

  const { data, error } = await supabase
    .from('battle_entries')
    .insert({ room_id: roomId, player_id: playerId, vote_count: 0 })
    .select()
    .single();

  if (error) throw error;
  return data as BattleEntry;
}

export async function submitBattleEntry(
  roomId: string,
  playerId: string,
  storyId: string,
  continuation: string
): Promise<BattleEntry> {
  const { data, error } = await supabase
    .from('battle_entries')
    .upsert({
      room_id: roomId,
      player_id: playerId,
      story_id: storyId,
      continuation,
      submitted_at: new Date().toISOString(),
    })
    .select()
    .single();

  if (error) throw error;
  return data as BattleEntry;
}

export async function castVote(roomId: string, voterId: string, entryId: string) {
  // Prevent self-voting
  const { data: entry } = await supabase
    .from('battle_entries')
    .select('player_id')
    .eq('id', entryId)
    .single();

  if (!entry) throw new Error('Entry not found');
  if (entry.player_id === voterId) throw new Error('Cannot vote for your own entry');

  const { error } = await supabase
    .from('votes')
    .insert({ room_id: roomId, voter_id: voterId, entry_id: entryId });

  if (error?.code === '23505') throw new Error('Already voted');
  if (error) throw error;

  // Increment vote count
  const { data } = await supabase.rpc('increment_vote', { entry_id: entryId });
  return data;
}

export async function getResults(roomId: string) {
  const { data, error } = await supabase
    .from('battle_entries')
    .select(`
      *,
      profiles ( username, avatar_url ),
      stories ( content ),
      story_blanks: stories ( story_blanks ( * ) )
    `)
    .eq('room_id', roomId)
    .order('vote_count', { ascending: false });

  if (error) throw error;
  return data;
}

export async function allPlayersSubmitted(roomId: string): Promise<boolean> {
  const { data: players } = await supabase
    .from('room_players')
    .select('player_id')
    .eq('room_id', roomId);

  const { data: entries } = await supabase
    .from('battle_entries')
    .select('player_id, submitted_at')
    .eq('room_id', roomId);

  if (!players || !entries) return false;

  const submittedIds = new Set(entries.filter((e) => e.submitted_at).map((e) => e.player_id));
  return players.every((p) => submittedIds.has(p.player_id));
}
