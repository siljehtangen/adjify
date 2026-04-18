export type GameMode = 'fill_reveal' | 'rotating_chain' | 'battle';
export type RoomStatus = 'waiting' | 'in_progress' | 'finished';
export type ChainSegmentType = 'sentence' | 'blank_fill';

export interface Profile {
  id: string;
  username: string;
  avatar_url?: string;
  created_at: string;
}

export interface Room {
  id: string;
  code: string;
  mode: GameMode;
  status: RoomStatus;
  host_id: string;
  max_players: number;
  created_at: string;
  started_at?: string;
  finished_at?: string;
}

export interface RoomPlayer {
  id: string;
  room_id: string;
  player_id: string;
  role: string;
  joined_at: string;
  profiles?: Profile;
}

export interface Story {
  id: string;
  room_id: string;
  content: string;
  created_by: string;
  created_at: string;
}

export interface StoryBlank {
  id: string;
  story_id: string;
  position: number;
  filled_by?: string;
  adjective?: string;
  filled_at?: string;
}

export interface ChainSegment {
  id: string;
  room_id: string;
  round_number: number;
  segment_type: ChainSegmentType;
  content?: string;
  author_id: string;
  created_at: string;
}

export interface BattleEntry {
  id: string;
  room_id: string;
  player_id: string;
  story_id?: string;
  continuation?: string;
  submitted_at?: string;
  vote_count: number;
}

export interface Vote {
  id: string;
  room_id: string;
  voter_id: string;
  entry_id: string;
  created_at: string;
}

// Socket event payloads
export interface SocketEvents {
  'room:joined': { room: Room; players: RoomPlayer[] };
  'room:player_joined': { player: RoomPlayer };
  'room:player_left': { playerId: string };
  'room:game_started': { room: Room };
  'game:blank_filled': { blankId: string; position: number; adjective: string; filledBy: string };
  'game:story_revealed': { story: Story; blanks: StoryBlank[] };
  'game:chain_turn': { playerId: string; segmentType: ChainSegmentType; previousContent?: string };
  'game:chain_submitted': { segment: ChainSegment };
  'game:battle_submitted': { playerId: string };
  'game:battle_reveal': { entries: BattleEntry[] };
  'game:vote_cast': { entryId: string; voteCount: number };
  'game:winner': { entryId: string; playerId: string };
}

export interface AuthenticatedUser {
  id: string;
  email: string;
  username?: string;
}
