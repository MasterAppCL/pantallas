-- Pega todo esto en Supabase › SQL Editor y presiona Run

create table if not exists anuncios (
  id uuid primary key default gen_random_uuid(),
  tipo text not null check (tipo in ('image','video','text')),
  titulo text default '',
  precio text default '',
  detalle text default '',
  duracion int default 8,
  orden int default 0,
  activo boolean default true,
  archivo text,
  creado timestamptz default now()
);

alter table anuncios enable row level security;

drop policy if exists "TV puede leer" on anuncios;
create policy "TV puede leer" on anuncios
  for select to anon, authenticated using (true);

drop policy if exists "Solo admin edita" on anuncios;
create policy "Solo admin edita" on anuncios
  for all to authenticated using (true) with check (true);

-- Carpeta pública para imágenes y videos
insert into storage.buckets (id, name, public)
values ('anuncios', 'anuncios', true)
on conflict (id) do nothing;

drop policy if exists "Admin sube archivos" on storage.objects;
create policy "Admin sube archivos" on storage.objects
  for insert to authenticated with check (bucket_id = 'anuncios');

drop policy if exists "Admin borra archivos" on storage.objects;
create policy "Admin borra archivos" on storage.objects
  for delete to authenticated using (bucket_id = 'anuncios');
