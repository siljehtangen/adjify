-- RPC: atomically increment vote count on battle_entries
create or replace function public.increment_vote(entry_id uuid)
returns void language plpgsql security definer as $$
begin
  update public.battle_entries
  set vote_count = vote_count + 1
  where id = entry_id;
end;
$$;
