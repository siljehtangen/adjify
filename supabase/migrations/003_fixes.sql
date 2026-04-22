-- Add missing vote_count column to battle_entries
alter table public.battle_entries
  add column if not exists vote_count int default 0 not null;

-- Fix story_blanks RLS: restrict reads to room members only (was open to all authenticated users)
drop policy if exists "story_blanks_select_all" on public.story_blanks;
create policy "story_blanks_select_room_member" on public.story_blanks for select
  using (exists (
    select 1 from public.stories s
    join public.room_players rp on rp.room_id = s.room_id
    where s.id = story_blanks.story_id and rp.player_id = auth.uid()
  ));

-- Fix battle_entries RLS: allow room members to see all submitted entries (needed for voting phase)
-- Previous policy blocked seeing other players' entries while room was still in_progress
drop policy if exists "battle_entries_select_after_reveal" on public.battle_entries;
create policy "battle_entries_select_submitted" on public.battle_entries for select
  using (
    submitted_at is not null and exists (
      select 1 from public.room_players rp
      where rp.room_id = battle_entries.room_id and rp.player_id = auth.uid()
    )
  );
