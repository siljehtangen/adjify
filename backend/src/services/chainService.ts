import { supabase } from '../config/supabase.js';
import { ChainSegment, ChainSegmentType } from '../types/index.js';

export async function getChainSegments(roomId: string): Promise<ChainSegment[]> {
  const { data, error } = await supabase
    .from('chain_segments')
    .select('*')
    .eq('room_id', roomId)
    .order('round_number', { ascending: true });

  if (error) throw error;
  return (data || []) as ChainSegment[];
}

export async function getLastSegment(roomId: string): Promise<ChainSegment | null> {
  const { data } = await supabase
    .from('chain_segments')
    .select('*')
    .eq('room_id', roomId)
    .order('round_number', { ascending: false })
    .limit(1)
    .maybeSingle();

  return (data as ChainSegment) || null;
}

export async function addChainSegment(
  roomId: string,
  authorId: string,
  segmentType: ChainSegmentType,
  content: string
): Promise<ChainSegment> {
  const last = await getLastSegment(roomId);
  const roundNumber = last ? last.round_number + 1 : 1;

  // Validate turn alternation: sentence ↔ blank_fill
  if (last) {
    const expectedType: ChainSegmentType =
      last.segment_type === 'sentence' ? 'blank_fill' : 'sentence';
    if (segmentType !== expectedType) {
      throw new Error(`Expected segment type "${expectedType}" but got "${segmentType}"`);
    }
  }

  const { data, error } = await supabase
    .from('chain_segments')
    .insert({ room_id: roomId, round_number: roundNumber, segment_type: segmentType, content, author_id: authorId })
    .select()
    .single();

  if (error) throw error;
  return data as ChainSegment;
}

export function getNextPlayer(playerIds: string[], lastAuthorId: string | null): string {
  if (!lastAuthorId) return playerIds[0];
  const idx = playerIds.indexOf(lastAuthorId);
  return playerIds[(idx + 1) % playerIds.length];
}
