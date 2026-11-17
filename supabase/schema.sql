-- =============================================================
-- Base de données pour "Liste des stagiaires"
-- À exécuter dans Supabase : SQL Editor → New query → Run
-- =============================================================

-- 1. Table des stagiaires
create table if not exists public.stagiaires (
  id         uuid primary key default gen_random_uuid(),
  name       text not null default '',
  number     text not null default '',
  date       text not null default '',
  cin        text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 2. Table des informations générales (une seule ligne, id = 1)
create table if not exists public.parametres (
  id            smallint primary key default 1 check (id = 1),
  filiere       text not null default '',
  specialite    text not null default '',
  cohorte       text not null default '',
  mode          text not null default '',
  niveau        text not null default '',
  etablissement text not null default '',
  updated_at    timestamptz not null default now()
);

-- Valeurs initiales
insert into public.parametres
  (id, filiere, specialite, cohorte, mode, niveau, etablissement)
values
  (1, 'SPECIALISATION', 'SPECIALISATION', '25/26', 'Résidentielle', 'Spécialisation', 'Institut de formation')
on conflict (id) do nothing;

-- 3. Mise à jour automatique de updated_at
create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_stagiaires_touch on public.stagiaires;
create trigger trg_stagiaires_touch
before update on public.stagiaires
for each row execute function public.touch_updated_at();

drop trigger if exists trg_parametres_touch on public.parametres;
create trigger trg_parametres_touch
before update on public.parametres
for each row execute function public.touch_updated_at();

-- 4. Accès via le lien partagé (aucun login)
--    La clé anon est publique : ces policies autorisent tout le monde
--    à lire / écrire. À remplacer par des policies avec authentification
--    si les données doivent être protégées.
alter table public.stagiaires enable row level security;
alter table public.parametres enable row level security;

drop policy if exists "anon_all_stagiaires" on public.stagiaires;
create policy "anon_all_stagiaires" on public.stagiaires
  for all to anon using (true) with check (true);

drop policy if exists "anon_all_parametres" on public.parametres;
create policy "anon_all_parametres" on public.parametres
  for all to anon using (true) with check (true);

-- 5. Temps réel : les modifications apparaissent sur tous les appareils
do $$
begin
  alter publication supabase_realtime add table public.stagiaires;
exception when duplicate_object then null;
end $$;

do $$
begin
  alter publication supabase_realtime add table public.parametres;
exception when duplicate_object then null;
end $$;
