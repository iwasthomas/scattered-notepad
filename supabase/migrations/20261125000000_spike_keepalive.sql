create or replace function public.keepalive()
returns timestamptz
language sql
security definer
set search_path = ''
as $$ select now(); $$;

revoke all on function public.keepalive() from public;
grant execute on function public.keepalive() to anon, authenticated;
