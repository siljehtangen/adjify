-- Enable required extensions
create extension if not exists "uuid-ossp";

-- Enums
create type public.room_status as enum ('waiting', 'in_progress', 'finished');
create type public.game_mode as enum ('fill_reveal', 'rotating_chain', 'battle');
create type public.chain_segment_type as enum ('sentence', 'blank_fill');

-- Profiles (extends auth.users)
create table public.profiles (
  id          uuid references auth.users on delete cascade primary key,
  username    text unique not null,
  avatar_url  text,
  created_at  timestamptz default now() not null
);

alter table public.profiles enable row level security;

create policy "profiles_select_all"  on public.profiles for select  using (true);
create policy "profiles_insert_own"  on public.profiles for insert  with check (auth.uid() = id);
create policy "profiles_update_own"  on public.profiles for update  using (auth.uid() = id);

-- Auto-create profile on signup
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, username, avatar_url)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'name', split_part(new.email, '@', 1)),
    new.raw_user_meta_data->>'avatar_url'
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Rooms
create table public.rooms (
  id          uuid default gen_random_uuid() primary key,
  code        text unique not null,
  mode        game_mode not null,
  status      room_status default 'waiting' not null,
  host_id     uuid references public.profiles(id) on delete set null,
  max_players int default 6 not null,
  created_at  timestamptz default now() not null,
  started_at  timestamptz,
  finished_at timestamptz
);

alter table public.rooms enable row level security;

create policy "rooms_select_all"   on public.rooms for select  using (true);
create policy "rooms_insert_auth"  on public.rooms for insert  with check (auth.uid() is not null);
create policy "rooms_update_host"  on public.rooms for update  using (auth.uid() = host_id);

-- Room players
create table public.room_players (
  id         uuid default gen_random_uuid() primary key,
  room_id    uuid references public.rooms(id) on delete cascade not null,
  player_id  uuid references public.profiles(id) on delete cascade not null,
  role       text default 'player' not null,
  joined_at  timestamptz default now() not null,
  unique(room_id, player_id)
);

alter table public.room_players enable row level security;

create policy "room_players_select_all"    on public.room_players for select  using (true);
create policy "room_players_insert_auth"   on public.room_players for insert  with check (auth.uid() = player_id);
create policy "room_players_delete_own"    on public.room_players for delete  using (auth.uid() = player_id);

-- Stories (used in fill_reveal and battle modes)
create table public.stories (
  id          uuid default gen_random_uuid() primary key,
  room_id     uuid references public.rooms(id) on delete cascade,
  content     text not null, -- raw text with [ADJ] placeholders
  created_by  uuid references public.profiles(id),
  created_at  timestamptz default now() not null
);

alter table public.stories enable row level security;

create policy "stories_select_room_member" on public.stories for select
  using (exists (
    select 1 from public.room_players rp
    where rp.room_id = stories.room_id and rp.player_id = auth.uid()
  ));
create policy "stories_insert_auth" on public.stories for insert
  with check (auth.uid() = created_by);

-- Story blanks (each [ADJ] slot)
create table public.story_blanks (
  id          uuid default gen_random_uuid() primary key,
  story_id    uuid references public.stories(id) on delete cascade not null,
  position    int not null,
  filled_by   uuid references public.profiles(id),
  adjective   text,
  filled_at   timestamptz,
  unique(story_id, position)
);

alter table public.story_blanks enable row level security;

create policy "story_blanks_select_all"  on public.story_blanks for select  using (true);
create policy "story_blanks_update_auth" on public.story_blanks for update  using (auth.uid() is not null and filled_by is null);
create policy "story_blanks_insert_auth" on public.story_blanks for insert  with check (auth.uid() is not null);

-- Chain segments (mode 2: rotating blind chain)
create table public.chain_segments (
  id            uuid default gen_random_uuid() primary key,
  room_id       uuid references public.rooms(id) on delete cascade not null,
  round_number  int not null,
  segment_type  chain_segment_type not null,
  content       text,
  author_id     uuid references public.profiles(id),
  created_at    timestamptz default now() not null
);

alter table public.chain_segments enable row level security;

create policy "chain_segments_select_room_member" on public.chain_segments for select
  using (exists (
    select 1 from public.room_players rp
    where rp.room_id = chain_segments.room_id and rp.player_id = auth.uid()
  ));
create policy "chain_segments_insert_room_member" on public.chain_segments for insert
  with check (auth.uid() = author_id);

-- Battle entries (mode 3)
create table public.battle_entries (
  id            uuid default gen_random_uuid() primary key,
  room_id       uuid references public.rooms(id) on delete cascade not null,
  player_id     uuid references public.profiles(id) not null,
  story_id      uuid references public.stories(id),
  continuation  text,
  submitted_at  timestamptz,
  unique(room_id, player_id)
);

alter table public.battle_entries enable row level security;

create policy "battle_entries_select_after_reveal" on public.battle_entries for select
  using (
    submitted_at is not null and exists (
      select 1 from public.rooms r
      where r.id = battle_entries.room_id
        and (r.status = 'finished' or auth.uid() = player_id)
    )
  );
create policy "battle_entries_insert_own" on public.battle_entries for insert
  with check (auth.uid() = player_id);
create policy "battle_entries_update_own" on public.battle_entries for update
  using (auth.uid() = player_id);

-- Votes (mode 3)
create table public.votes (
  id         uuid default gen_random_uuid() primary key,
  room_id    uuid references public.rooms(id) on delete cascade not null,
  voter_id   uuid references public.profiles(id) not null,
  entry_id   uuid references public.battle_entries(id) on delete cascade not null,
  created_at timestamptz default now() not null,
  unique(room_id, voter_id)
);

alter table public.votes enable row level security;

create policy "votes_select_all"   on public.votes for select  using (true);
create policy "votes_insert_auth"  on public.votes for insert
  with check (auth.uid() = voter_id and auth.uid() != (
    select player_id from public.battle_entries where id = votes.entry_id
  ));

-- Realtime subscriptions
alter publication supabase_realtime add table public.rooms;
alter publication supabase_realtime add table public.room_players;
alter publication supabase_realtime add table public.story_blanks;
alter publication supabase_realtime add table public.chain_segments;
alter publication supabase_realtime add table public.battle_entries;
alter publication supabase_realtime add table public.votes;
