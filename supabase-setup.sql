-- ZANVIQUE DATABASE SETUP
-- Run the entire script in Supabase > SQL Editor > New query.
-- This creates the canonical lowercase public.listings table used by the app.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  phone text,
  about text,
  is_admin boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.listings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  category text not null,
  price numeric(12,2),
  province text not null,
  town text not null,
  phone text not null,
  listing_type text not null default 'For sale',
  description text not null,
  image_url text,
  featured_requested boolean not null default false,
  is_featured boolean not null default false,
  status text not null default 'published' check (status in ('published','draft','removed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists listings_search_idx on public.listings(status, province, town, category, created_at desc);

create table if not exists public.business_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references auth.users(id) on delete cascade,
  name text not null,
  category text not null,
  province text not null,
  town text not null,
  phone text not null,
  description text,
  created_at timestamptz not null default now()
);

create table if not exists public.favorites (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  listing_id uuid not null references public.listings(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(user_id, listing_id)
);

create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  listing_id uuid not null references public.listings(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  rating int not null check (rating between 1 and 5),
  comment text,
  created_at timestamptz not null default now(),
  unique(listing_id,user_id)
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  message text not null,
  read boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.listings enable row level security;
alter table public.business_profiles enable row level security;
alter table public.favorites enable row level security;
alter table public.reviews enable row level security;
alter table public.notifications enable row level security;

drop policy if exists "Profiles are viewable by everyone" on public.profiles;
create policy "Profiles are viewable by everyone" on public.profiles for select using (true);
drop policy if exists "Users insert own profile" on public.profiles;
create policy "Users insert own profile" on public.profiles for insert with check (auth.uid() = id);
drop policy if exists "Users update own profile" on public.profiles;
create policy "Users update own profile" on public.profiles for update using (auth.uid() = id) with check (auth.uid() = id);

drop policy if exists "Published listings are public" on public.listings;
create policy "Published listings are public" on public.listings for select using (status = 'published' or auth.uid() = user_id);
drop policy if exists "Users create own listings" on public.listings;
create policy "Users create own listings" on public.listings for insert with check (auth.uid() = user_id);
drop policy if exists "Users update own listings" on public.listings;
create policy "Users update own listings" on public.listings for update using (auth.uid() = user_id or exists(select 1 from public.profiles p where p.id=auth.uid() and p.is_admin)) with check (auth.uid() = user_id or exists(select 1 from public.profiles p where p.id=auth.uid() and p.is_admin));
drop policy if exists "Owners and admins delete listings" on public.listings;
create policy "Owners and admins delete listings" on public.listings for delete using (auth.uid() = user_id or exists(select 1 from public.profiles p where p.id=auth.uid() and p.is_admin));

drop policy if exists "Businesses are public" on public.business_profiles;
create policy "Businesses are public" on public.business_profiles for select using (true);
drop policy if exists "Owners manage business profile" on public.business_profiles;
create policy "Owners manage business profile" on public.business_profiles for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "Users manage own favorites" on public.favorites;
create policy "Users manage own favorites" on public.favorites for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "Reviews are public" on public.reviews;
create policy "Reviews are public" on public.reviews for select using (true);
drop policy if exists "Authenticated users create reviews" on public.reviews;
create policy "Authenticated users create reviews" on public.reviews for insert with check (auth.uid() = user_id);
drop policy if exists "Users update own reviews" on public.reviews;
create policy "Users update own reviews" on public.reviews for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "Users see own notifications" on public.notifications;
create policy "Users see own notifications" on public.notifications for select using (auth.uid() = user_id);
drop policy if exists "Users update own notifications" on public.notifications;
create policy "Users update own notifications" on public.notifications for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Storage bucket for listing photos (public read; authenticated users upload to their own folder).
insert into storage.buckets (id,name,public) values ('listing-images','listing-images',true)
on conflict (id) do update set public=true;
drop policy if exists "Listing photos are public" on storage.objects;
create policy "Listing photos are public" on storage.objects for select using (bucket_id='listing-images');
drop policy if exists "Users upload listing photos to own folder" on storage.objects;
create policy "Users upload listing photos to own folder" on storage.objects for insert to authenticated
with check (bucket_id='listing-images' and (storage.foldername(name))[1]=auth.uid()::text);
drop policy if exists "Users update own listing photos" on storage.objects;
create policy "Users update own listing photos" on storage.objects for update to authenticated
using (bucket_id='listing-images' and (storage.foldername(name))[1]=auth.uid()::text)
with check (bucket_id='listing-images' and (storage.foldername(name))[1]=auth.uid()::text);
drop policy if exists "Users delete own listing photos" on storage.objects;
create policy "Users delete own listing photos" on storage.objects for delete to authenticated
using (bucket_id='listing-images' and (storage.foldername(name))[1]=auth.uid()::text);

-- After creating your account, make yourself admin with:
-- update public.profiles set is_admin = true where id = 'YOUR_AUTH_USER_UUID';
-- First create profile row if needed:
-- insert into public.profiles(id, full_name) values ('YOUR_AUTH_USER_UUID','Admin name') on conflict (id) do nothing;
