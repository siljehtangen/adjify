import { supabase } from '../config/supabase.js';
import { Story, StoryBlank } from '../types/index.js';

/** Count [ADJ] placeholders in a story string */
export function countBlanks(content: string): number {
  return (content.match(/\[ADJ\]/g) || []).length;
}

/** Create a story and seed its blank rows */
export async function createStory(roomId: string, content: string, createdBy: string): Promise<Story> {
  const { data: story, error } = await supabase
    .from('stories')
    .insert({ room_id: roomId, content, created_by: createdBy })
    .select()
    .single();

  if (error) throw error;

  const blankCount = countBlanks(content);
  if (blankCount > 0) {
    const blanks = Array.from({ length: blankCount }, (_, i) => ({
      story_id: story.id,
      position: i,
    }));

    const { error: blankError } = await supabase.from('story_blanks').insert(blanks);
    if (blankError) throw blankError;
  }

  return story as Story;
}

export async function getStoryWithBlanks(storyId: string) {
  const { data, error } = await supabase
    .from('stories')
    .select('*, story_blanks(*)')
    .eq('id', storyId)
    .order('position', { referencedTable: 'story_blanks' })
    .single();

  if (error) throw error;
  return data;
}

/** Fill one blank. Returns the updated blank and whether the story is fully complete. */
export async function fillBlank(
  storyId: string,
  position: number,
  adjective: string,
  filledBy: string
): Promise<{ blank: StoryBlank; isComplete: boolean }> {
  const { data: existing, error: fetchError } = await supabase
    .from('story_blanks')
    .select('*')
    .eq('story_id', storyId)
    .eq('position', position)
    .single();

  if (fetchError || !existing) throw new Error('Blank not found');
  if (existing.filled_by) throw new Error('Blank already filled');

  const { data: blank, error } = await supabase
    .from('story_blanks')
    .update({ adjective, filled_by: filledBy, filled_at: new Date().toISOString() })
    .eq('story_id', storyId)
    .eq('position', position)
    .select()
    .single();

  if (error) throw error;

  const { data: allBlanks } = await supabase
    .from('story_blanks')
    .select('filled_by')
    .eq('story_id', storyId);

  const isComplete = (allBlanks || []).every((b) => b.filled_by !== null);

  return { blank: blank as StoryBlank, isComplete };
}

/** Render the full story by replacing [ADJ] placeholders with filled adjectives */
export function renderStory(content: string, blanks: StoryBlank[]): string {
  const sorted = [...blanks].sort((a, b) => a.position - b.position);
  let result = content;
  for (const blank of sorted) {
    result = result.replace('[ADJ]', blank.adjective ?? '___');
  }
  return result;
}
