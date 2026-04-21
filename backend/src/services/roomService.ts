import { supabase } from '../config/supabase.js';
import { Room, GameMode } from '../types/index.js';

function generateRoomCode(): string {
  return Math.random().toString(36).substring(2, 8).toUpperCase();
}

async function ensureProfile(hostId: string): Promise<void> {
  const { data: existing } = await supabase
    .from('profiles')
    .select('id')
    .eq('id', hostId)
    .single();

  if (existing) return;

  const { data: authUser } = await supabase.auth.admin.getUserById(hostId);
  const email = authUser?.user?.email ?? '';
  const username =
    (authUser?.user?.user_metadata?.name as string | undefined) ??
    email.split('@')[0] ??
    'player';

  await supabase.from('profiles').upsert({ id: hostId, username });
}

export async function createRoom(hostId: string, mode: GameMode, maxPlayers: number): Promise<Room> {
  await ensureProfile(hostId);

  let code = generateRoomCode();
  let attempts = 0;

  // Ensure unique code
  while (attempts < 5) {
    const { data } = await supabase.from('rooms').select('id').eq('code', code).single();
    if (!data) break;
    code = generateRoomCode();
    attempts++;
  }

  const { data, error } = await supabase
    .from('rooms')
    .insert({ code, mode, host_id: hostId, max_players: maxPlayers })
    .select()
    .single();

  if (error) throw error;

  // Auto-join host as 'host' role
  await supabase
    .from('room_players')
    .insert({ room_id: data.id, player_id: hostId, role: 'host' });

  return data as Room;
}

export async function getRoomByCode(code: string) {
  const { data, error } = await supabase
    .from('rooms')
    .select(`
      *,
      room_players (
        *,
        profiles ( id, username, avatar_url )
      )
    `)
    .eq('code', code.toUpperCase())
    .single();

  if (error) throw error;
  return data;
}

export async function joinRoom(code: string, playerId: string) {
  await ensureProfile(playerId);
  const room = await getRoomByCode(code);

  if (!room) throw new Error('Room not found');
  if (room.status !== 'waiting') throw new Error('Game already started');
  if (room.room_players.length >= room.max_players) throw new Error('Room is full');

  const alreadyJoined = room.room_players.some((p: { player_id: string }) => p.player_id === playerId);
  if (alreadyJoined) return room;

  const { error } = await supabase
    .from('room_players')
    .insert({ room_id: room.id, player_id: playerId, role: 'player' });

  if (error) throw error;
  return getRoomByCode(code);
}

export async function leaveRoom(roomId: string, playerId: string) {
  const { error } = await supabase
    .from('room_players')
    .delete()
    .eq('room_id', roomId)
    .eq('player_id', playerId);

  if (error) throw error;
}

export async function getPlayerListForRoom(roomId: string): Promise<string[]> {
  const { data: players } = await supabase
    .from('room_players')
    .select('player_id')
    .eq('room_id', roomId)
    .order('joined_at');
  return (players || []).map((p: { player_id: string }) => p.player_id);
}

export async function startGame(roomId: string, hostId: string) {
  const { data: room, error } = await supabase
    .from('rooms')
    .select('*, room_players(*)')
    .eq('id', roomId)
    .single();

  if (error || !room) throw new Error('Room not found');
  if (room.host_id !== hostId) throw new Error('Only the host can start the game');
  if (room.status !== 'waiting') throw new Error('Game already started');

  const minPlayers: Record<string, number> = {
    fill_reveal: 1,
    rotating_chain: 2,
    battle: 2,
  };

  if (room.room_players.length < minPlayers[room.mode]) {
    throw new Error(`Need at least ${minPlayers[room.mode]} players for this mode`);
  }

  const { data: updated, error: updateError } = await supabase
    .from('rooms')
    .update({ status: 'in_progress', started_at: new Date().toISOString() })
    .eq('id', roomId)
    .select()
    .single();

  if (updateError) throw updateError;
  return updated as Room;
}
