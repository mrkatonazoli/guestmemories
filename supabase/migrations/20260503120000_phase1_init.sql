-- =============================================================================
-- Phase 1 — identity, organization, audit, i18n + RLS
-- =============================================================================
-- Security stance:
--  * RLS enabled and FORCED on every table (table-owner cannot bypass).
--  * No DELETE policies are granted to authenticated users — soft delete only
--    via UPDATE deleted_at. Hard deletes happen via service_role for admin ops.
--  * Helper functions are SECURITY DEFINER with locked search_path, used inside
--    policies to avoid recursion on self-referential checks.
--  * `is_superadmin` flag is trigger-protected: only an existing superadmin
--    may change it.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Extensions
-- -----------------------------------------------------------------------------
create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

-- -----------------------------------------------------------------------------
-- Enums
-- -----------------------------------------------------------------------------
create type hotel_role as enum ('owner', 'manager', 'staff', 'viewer');

-- -----------------------------------------------------------------------------
-- Generic updated_at trigger function (no table dependency)
-- -----------------------------------------------------------------------------
create or replace function gm_set_updated_at() returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

-- =============================================================================
-- Tables (created BEFORE helper functions that reference them)
-- =============================================================================

-- profiles  (extends auth.users)
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  full_name text,
  preferred_language text not null default 'hu',
  is_superadmin boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create trigger trg_profiles_updated_at
  before update on profiles
  for each row execute function gm_set_updated_at();

-- hotel_groups
create table hotel_groups (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  slug text unique not null,
  default_theme jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create trigger trg_hotel_groups_updated_at
  before update on hotel_groups
  for each row execute function gm_set_updated_at();

-- hotels
create table hotels (
  id uuid primary key default uuid_generate_v4(),
  group_id uuid references hotel_groups(id) on delete set null,
  name text not null,
  slug text unique not null,
  address text,
  city text,
  country text,
  timezone text not null default 'UTC',
  website_url text,
  theme jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index idx_hotels_group on hotels(group_id) where deleted_at is null;

create trigger trg_hotels_updated_at
  before update on hotels
  for each row execute function gm_set_updated_at();

-- hotel_memberships
create table hotel_memberships (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references profiles(id) on delete cascade,
  hotel_id uuid not null references hotels(id) on delete cascade,
  role hotel_role not null,
  invited_by uuid references profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  unique (user_id, hotel_id)
);

create index idx_memberships_user on hotel_memberships(user_id) where deleted_at is null;
create index idx_memberships_hotel on hotel_memberships(hotel_id) where deleted_at is null;

create trigger trg_memberships_updated_at
  before update on hotel_memberships
  for each row execute function gm_set_updated_at();

-- audit_log  (immutable; only service_role writes)
create table audit_log (
  id uuid primary key default uuid_generate_v4(),
  actor_id uuid references profiles(id) on delete set null,
  hotel_id uuid references hotels(id) on delete set null,
  action text not null,
  target_type text,
  target_id uuid,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index idx_audit_hotel on audit_log(hotel_id, created_at desc);
create index idx_audit_actor on audit_log(actor_id, created_at desc);

-- translations  (global UI strings)
create table translations (
  key text not null,
  language text not null,
  value text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (key, language)
);

create trigger trg_translations_updated_at
  before update on translations
  for each row execute function gm_set_updated_at();

-- hotel_translations  (per-hotel overrides)
create table hotel_translations (
  hotel_id uuid not null references hotels(id) on delete cascade,
  key text not null,
  language text not null,
  value text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (hotel_id, key, language)
);

create trigger trg_hotel_translations_updated_at
  before update on hotel_translations
  for each row execute function gm_set_updated_at();

-- =============================================================================
-- Helper / trigger functions  (after tables exist)
-- =============================================================================

-- Auto-create profile when an auth.user is inserted.
create or replace function gm_handle_new_user() returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  insert into public.profiles (id, email, preferred_language)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'preferred_language', 'hu')
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function gm_handle_new_user();

-- Protect the is_superadmin flag — only existing superadmin may change it.
create or replace function gm_protect_superadmin_flag() returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  caller_is_super boolean;
begin
  if new.is_superadmin is distinct from old.is_superadmin then
    select coalesce(p.is_superadmin, false) into caller_is_super
      from profiles p where p.id = auth.uid() and p.deleted_at is null;
    if not coalesce(caller_is_super, false) then
      raise exception 'Only a superadmin can change is_superadmin';
    end if;
  end if;
  return new;
end;
$$;

create trigger trg_profiles_protect_superadmin
  before update on profiles
  for each row execute function gm_protect_superadmin_flag();

-- Prevent removal/demotion of the last owner of a hotel.
create or replace function gm_prevent_last_owner_removal() returns trigger
language plpgsql
as $$
begin
  if (old.role = 'owner' and new.role <> 'owner')
     or (old.deleted_at is null and new.deleted_at is not null and old.role = 'owner') then
    if not exists (
      select 1 from hotel_memberships
      where hotel_id = old.hotel_id
        and role = 'owner'
        and deleted_at is null
        and id <> old.id
    ) then
      raise exception 'Cannot remove or demote the last owner of hotel %', old.hotel_id;
    end if;
  end if;
  return new;
end;
$$;

create trigger trg_memberships_prevent_last_owner
  before update on hotel_memberships
  for each row execute function gm_prevent_last_owner_removal();

-- =============================================================================
-- RLS helper functions
-- (SECURITY DEFINER + locked search_path, safe to call from policies)
-- =============================================================================

create or replace function gm_is_superadmin() returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select coalesce(
    (select is_superadmin from profiles
      where id = auth.uid() and deleted_at is null),
    false
  );
$$;

create or replace function gm_role_rank(r hotel_role) returns int
language sql
immutable
as $$
  select case r
    when 'viewer'  then 1
    when 'staff'   then 2
    when 'manager' then 3
    when 'owner'   then 4
  end;
$$;

create or replace function gm_hotel_role(hotel_uuid uuid) returns hotel_role
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select role from hotel_memberships
   where hotel_id = hotel_uuid
     and user_id = auth.uid()
     and deleted_at is null
   limit 1;
$$;

create or replace function gm_has_hotel_role(hotel_uuid uuid, min_role hotel_role)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select gm_is_superadmin()
    or coalesce(gm_role_rank(gm_hotel_role(hotel_uuid)) >= gm_role_rank(min_role), false);
$$;

-- =============================================================================
-- ENABLE + FORCE Row Level Security
-- =============================================================================
alter table profiles            enable row level security;
alter table hotel_groups        enable row level security;
alter table hotels              enable row level security;
alter table hotel_memberships   enable row level security;
alter table audit_log           enable row level security;
alter table translations        enable row level security;
alter table hotel_translations  enable row level security;

alter table profiles            force row level security;
alter table hotel_groups        force row level security;
alter table hotels              force row level security;
alter table hotel_memberships   force row level security;
alter table audit_log           force row level security;
alter table translations        force row level security;
alter table hotel_translations  force row level security;

-- =============================================================================
-- Policies — profiles
-- =============================================================================
create policy profiles_select_self on profiles
  for select to authenticated
  using (id = auth.uid() and deleted_at is null);

create policy profiles_select_comembers on profiles
  for select to authenticated
  using (
    deleted_at is null and exists (
      select 1
        from hotel_memberships m1
        join hotel_memberships m2 on m1.hotel_id = m2.hotel_id
       where m1.user_id = auth.uid()
         and m2.user_id = profiles.id
         and m1.deleted_at is null
         and m2.deleted_at is null
    )
  );

create policy profiles_select_superadmin on profiles
  for select to authenticated using (gm_is_superadmin());

create policy profiles_update_self on profiles
  for update to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

create policy profiles_update_superadmin on profiles
  for update to authenticated
  using (gm_is_superadmin())
  with check (gm_is_superadmin());

-- INSERT happens only via the on_auth_user_created trigger (SECURITY DEFINER).
-- DELETE is service_role only — no policy.

-- =============================================================================
-- Policies — hotel_groups
-- =============================================================================
create policy hotel_groups_select on hotel_groups
  for select to authenticated using (
    deleted_at is null and (
      gm_is_superadmin()
      or exists (
        select 1
          from hotels h
          join hotel_memberships m on m.hotel_id = h.id
         where h.group_id = hotel_groups.id
           and m.user_id = auth.uid()
           and m.deleted_at is null
           and h.deleted_at is null
      )
    )
  );

create policy hotel_groups_insert on hotel_groups
  for insert to authenticated with check (gm_is_superadmin());

create policy hotel_groups_update on hotel_groups
  for update to authenticated
  using (gm_is_superadmin())
  with check (gm_is_superadmin());

-- =============================================================================
-- Policies — hotels
-- =============================================================================
create policy hotels_select on hotels
  for select to authenticated using (
    deleted_at is null and (
      gm_is_superadmin()
      or exists (
        select 1 from hotel_memberships m
         where m.hotel_id = hotels.id
           and m.user_id = auth.uid()
           and m.deleted_at is null
      )
    )
  );

create policy hotels_insert on hotels
  for insert to authenticated with check (gm_is_superadmin());

create policy hotels_update on hotels
  for update to authenticated
  using (gm_has_hotel_role(hotels.id, 'manager'::hotel_role))
  with check (gm_has_hotel_role(hotels.id, 'manager'::hotel_role));

-- =============================================================================
-- Policies — hotel_memberships
-- =============================================================================
create policy memberships_select on hotel_memberships
  for select to authenticated using (
    gm_is_superadmin()
    or user_id = auth.uid()
    or gm_has_hotel_role(hotel_memberships.hotel_id, 'staff'::hotel_role)
  );

create policy memberships_insert on hotel_memberships
  for insert to authenticated with check (
    gm_has_hotel_role(hotel_id, 'owner'::hotel_role)
  );

create policy memberships_update on hotel_memberships
  for update to authenticated
  using (
    gm_has_hotel_role(hotel_id, 'owner'::hotel_role)
    or user_id = auth.uid()
  )
  with check (
    gm_has_hotel_role(hotel_id, 'owner'::hotel_role)
    or user_id = auth.uid()
  );

-- =============================================================================
-- Policies — audit_log  (read-only for authenticated; writes via service_role)
-- =============================================================================
create policy audit_log_select on audit_log
  for select to authenticated using (
    gm_is_superadmin()
    or (hotel_id is not null and gm_has_hotel_role(hotel_id, 'manager'::hotel_role))
  );

-- =============================================================================
-- Policies — translations
-- =============================================================================
create policy translations_select_authenticated on translations
  for select to authenticated using (true);

create policy translations_select_anon on translations
  for select to anon using (true);

create policy translations_insert on translations
  for insert to authenticated with check (gm_is_superadmin());

create policy translations_update on translations
  for update to authenticated
  using (gm_is_superadmin())
  with check (gm_is_superadmin());

-- =============================================================================
-- Policies — hotel_translations
-- =============================================================================
create policy hotel_translations_select on hotel_translations
  for select to authenticated using (
    gm_has_hotel_role(hotel_id, 'staff'::hotel_role)
  );

create policy hotel_translations_insert on hotel_translations
  for insert to authenticated with check (
    gm_has_hotel_role(hotel_id, 'manager'::hotel_role)
  );

create policy hotel_translations_update on hotel_translations
  for update to authenticated
  using (gm_has_hotel_role(hotel_id, 'manager'::hotel_role))
  with check (gm_has_hotel_role(hotel_id, 'manager'::hotel_role));

-- =============================================================================
-- Seed minimal translations  (idempotent)
-- =============================================================================
insert into translations (key, language, value) values
  ('admin.nav.dashboard',       'hu', 'Áttekintés'),
  ('admin.nav.dashboard',       'en', 'Dashboard'),
  ('admin.nav.hotels',          'hu', 'Szállodák'),
  ('admin.nav.hotels',          'en', 'Hotels'),
  ('admin.nav.reviews',         'hu', 'Vélemények'),
  ('admin.nav.reviews',         'en', 'Reviews'),
  ('admin.nav.widgets',         'hu', 'Widgetek'),
  ('admin.nav.widgets',         'en', 'Widgets'),
  ('admin.nav.stats',           'hu', 'Statisztikák'),
  ('admin.nav.stats',           'en', 'Statistics'),
  ('admin.nav.settings',        'hu', 'Beállítások'),
  ('admin.nav.settings',        'en', 'Settings'),
  ('admin.empty.no_hotels',     'hu', 'Még nincs szálloda. Hozz létre egyet, hogy elindulj.'),
  ('admin.empty.no_hotels',     'en', 'No hotels yet. Create one to get started.'),
  ('admin.action.create_hotel', 'hu', 'Új szálloda'),
  ('admin.action.create_hotel', 'en', 'Create hotel'),
  ('admin.auth.sign_in',        'hu', 'Bejelentkezés'),
  ('admin.auth.sign_in',        'en', 'Sign in'),
  ('admin.auth.sign_out',       'hu', 'Kijelentkezés'),
  ('admin.auth.sign_out',       'en', 'Sign out')
on conflict (key, language) do nothing;
