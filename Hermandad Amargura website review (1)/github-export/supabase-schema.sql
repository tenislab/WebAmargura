-- ============================================================================
--  HERMANDAD DE LA AMARGURA · Esquema completo de base de datos
--  La Línea de la Concepción (Cádiz)
--
--  CÓMO USARLO:
--   1. Entra en tu proyecto de Supabase
--   2. Menú lateral → SQL Editor → New query
--   3. Pega TODO este archivo y pulsa RUN
--   4. Después sigue los pasos del final para crear el usuario administrador
-- ============================================================================


-- ============================================================================
--  1. TABLA DE HERMANOS (censo)
-- ============================================================================
-- Cada hermano se enlaza con su usuario de Supabase Auth mediante user_id.
-- El rol decide si ve solo lo suyo ('hermano') o todo el panel ('admin').

create table if not exists public.hermanos (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid unique references auth.users(id) on delete set null,
  num           text unique not null,               -- nº de hermano
  nombre        text not null,
  dni           text,
  email         text,
  telefono      text,
  direccion     text,
  iban          text,                               -- domiciliación SEPA
  desde         text,                               -- 'Desde 1998'
  rol           text not null default 'hermano'     -- 'hermano' | 'admin'
                check (rol in ('hermano','admin')),
  acceso        boolean not null default false,     -- ¿tiene portal activo?
  debe_cambiar_password boolean not null default true,
  activo        boolean not null default true,
  created_at    timestamptz not null default now()
);

create index if not exists hermanos_user_id_idx on public.hermanos(user_id);
create index if not exists hermanos_num_idx     on public.hermanos(num);


-- ============================================================================
--  2. CUOTAS Y RECIBOS
-- ============================================================================
-- Fuente ÚNICA de verdad: el hermano y la Secretaría leen esta misma tabla.
-- estado: 'Pendiente' | 'Pagado'
-- avisado: el hermano dice haber hecho el Bizum, pero AÚN NO está confirmado.
--          Solo la Secretaría puede pasarlo a 'Pagado'.

create table if not exists public.cuotas (
  id            bigint generated always as identity primary key,
  hermano_id    uuid not null references public.hermanos(id) on delete cascade,
  concepto      text not null,                      -- 'Cuota anual 2026'
  detalle       text,                               -- 'Domiciliada · 31/01/2026'
  importe       numeric(10,2) not null,
  estado        text not null default 'Pendiente'
                check (estado in ('Pendiente','Pagado')),
  avisado       boolean not null default false,
  metodo_pago   text,                               -- Bizum | Domiciliación | Efectivo
  fecha_pago    date,
  ejercicio     int,                                -- 2026
  created_at    timestamptz not null default now()
);

create index if not exists cuotas_hermano_idx on public.cuotas(hermano_id);
create index if not exists cuotas_estado_idx  on public.cuotas(estado);


-- ============================================================================
--  3. DONATIVOS
-- ============================================================================
-- hermano_id puede ser NULL: hay donantes que no son hermanos (o anónimos).

create table if not exists public.donativos (
  id            bigint generated always as identity primary key,
  hermano_id    uuid references public.hermanos(id) on delete set null,
  nombre        text not null,                      -- 'Anónimo' si procede
  concepto      text not null,
  importe       numeric(10,2) not null,
  metodo        text,                               -- Bizum | Efectivo | Transferencia
  fecha         date not null default current_date,
  campania_id   bigint,
  created_at    timestamptz not null default now()
);


-- ============================================================================
--  4. CAMPAÑAS DE RECAUDACIÓN (barra de progreso)
-- ============================================================================

create table if not exists public.campanias (
  id            bigint generated always as identity primary key,
  titulo        text not null,
  objetivo      numeric(10,2) not null,
  recaudado     numeric(10,2) not null default 0,
  activa        boolean not null default true,
  created_at    timestamptz not null default now()
);

alter table public.donativos
  drop constraint if exists donativos_campania_fk;
alter table public.donativos
  add constraint donativos_campania_fk
  foreign key (campania_id) references public.campanias(id) on delete set null;


-- ============================================================================
--  5. CONTENIDO DE LA WEB
-- ============================================================================

-- Páginas fijas (Titulares, Historia, Junta, Sede, Casa, Heráldica, Caridad…)
-- bloques: [{ "subtitulo": "...", "texto": "..." }]
-- fotos:   ["https://...", ...]
create table if not exists public.paginas (
  id            bigint generated always as identity primary key,
  slug          text unique not null,               -- 'historia', 'caridad'…
  icono         text,
  nombre        text not null,
  antetitulo    text,
  titulo        text not null,
  entradilla    text,
  bloques       jsonb not null default '[]'::jsonb,
  fotos         jsonb not null default '[]'::jsonb,
  orden         int not null default 0,
  updated_at    timestamptz not null default now()
);

-- Noticias de Actualidad
create table if not exists public.noticias (
  id            bigint generated always as identity primary key,
  titulo        text not null,
  fecha         text not null,                      -- '14 Marzo 2026'
  extracto      text,
  texto         text,
  imagen_url    text,
  estado        text not null default 'Borrador'
                check (estado in ('Publicada','Borrador')),
  created_at    timestamptz not null default now()
);

-- Agenda de cultos y actos
create table if not exists public.cultos (
  id            bigint generated always as identity primary key,
  dia           text not null,
  mes           text not null,
  titulo        text not null,
  detalle       text,
  orden         int not null default 0
);

-- Boletines en PDF (el archivo va a Storage, aquí solo la URL)
create table if not exists public.boletines (
  id            bigint generated always as identity primary key,
  titulo        text not null,
  meta          text,
  url           text,
  orden         int not null default 0,
  created_at    timestamptz not null default now()
);

-- Fotos rotatorias de la cabecera de inicio
create table if not exists public.fotos_portada (
  id            bigint generated always as identity primary key,
  url           text not null,
  orden         int not null default 0
);

-- Ajustes sueltos (número de Bizum, textos de contacto…)
create table if not exists public.ajustes (
  clave         text primary key,
  valor         text
);

insert into public.ajustes (clave, valor) values
  ('bizum_numero', '623 200 617')
on conflict (clave) do nothing;


-- ============================================================================
--  6. SOLICITUDES Y AVISOS
-- ============================================================================

-- Formulario "Hazte hermano" y "Únete al Grupo Joven" de la web pública
create table if not exists public.solicitudes (
  id            bigint generated always as identity primary key,
  tipo          text not null check (tipo in ('hermano','grupo_joven','contacto')),
  nombre        text not null,
  email         text,
  telefono      text,
  edad          text,
  mensaje       text,
  atendida      boolean not null default false,
  created_at    timestamptz not null default now()
);

-- El hermano avisa de que ha hecho el Bizum (NO confirma el pago)
create table if not exists public.avisos_pago (
  id            bigint generated always as identity primary key,
  cuota_id      bigint not null references public.cuotas(id) on delete cascade,
  hermano_id    uuid not null references public.hermanos(id) on delete cascade,
  created_at    timestamptz not null default now()
);


-- ============================================================================
--  7. FUNCIONES AUXILIARES
-- ============================================================================

-- ¿El usuario que hace la petición es administrador?
create or replace function public.es_admin()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from public.hermanos
    where user_id = auth.uid() and rol = 'admin'
  );
$$;

-- Id del hermano que hace la petición
create or replace function public.mi_hermano_id()
returns uuid
language sql
security definer
set search_path = public
stable
as $$
  select id from public.hermanos where user_id = auth.uid() limit 1;
$$;


-- ============================================================================
--  8. ROW LEVEL SECURITY
--  Cada hermano ve SOLO lo suyo. El admin lo ve y edita todo.
--  El contenido de la web lo lee cualquiera (es público) pero solo escribe admin.
-- ============================================================================

alter table public.hermanos      enable row level security;
alter table public.cuotas        enable row level security;
alter table public.donativos     enable row level security;
alter table public.campanias     enable row level security;
alter table public.paginas       enable row level security;
alter table public.noticias      enable row level security;
alter table public.cultos        enable row level security;
alter table public.boletines     enable row level security;
alter table public.fotos_portada enable row level security;
alter table public.ajustes       enable row level security;
alter table public.solicitudes   enable row level security;
alter table public.avisos_pago   enable row level security;

-- ---- HERMANOS -------------------------------------------------------------
drop policy if exists "hermano ve su ficha" on public.hermanos;
create policy "hermano ve su ficha" on public.hermanos
  for select using (user_id = auth.uid() or public.es_admin());

drop policy if exists "hermano edita su ficha" on public.hermanos;
create policy "hermano edita su ficha" on public.hermanos
  for update using (user_id = auth.uid() or public.es_admin());

drop policy if exists "admin gestiona el censo" on public.hermanos;
create policy "admin gestiona el censo" on public.hermanos
  for all using (public.es_admin()) with check (public.es_admin());

-- ---- CUOTAS ---------------------------------------------------------------
drop policy if exists "hermano ve sus cuotas" on public.cuotas;
create policy "hermano ve sus cuotas" on public.cuotas
  for select using (hermano_id = public.mi_hermano_id() or public.es_admin());

-- IMPORTANTE: el hermano solo puede marcar 'avisado'. Nunca 'Pagado'.
drop policy if exists "solo admin cobra" on public.cuotas;
create policy "solo admin cobra" on public.cuotas
  for all using (public.es_admin()) with check (public.es_admin());

-- ---- DONATIVOS ------------------------------------------------------------
drop policy if exists "hermano ve sus donativos" on public.donativos;
create policy "hermano ve sus donativos" on public.donativos
  for select using (hermano_id = public.mi_hermano_id() or public.es_admin());

drop policy if exists "admin gestiona donativos" on public.donativos;
create policy "admin gestiona donativos" on public.donativos
  for all using (public.es_admin()) with check (public.es_admin());

-- ---- AVISOS DE PAGO -------------------------------------------------------
drop policy if exists "hermano avisa de su pago" on public.avisos_pago;
create policy "hermano avisa de su pago" on public.avisos_pago
  for insert with check (hermano_id = public.mi_hermano_id());

drop policy if exists "admin ve los avisos" on public.avisos_pago;
create policy "admin ve los avisos" on public.avisos_pago
  for select using (public.es_admin() or hermano_id = public.mi_hermano_id());

-- ---- CONTENIDO PÚBLICO ----------------------------------------------------
-- Lectura abierta a todo el mundo (la web es pública), escritura solo admin.
do $$
declare t text;
begin
  foreach t in array array['paginas','noticias','cultos','boletines','fotos_portada','ajustes','campanias']
  loop
    execute format('drop policy if exists "lectura publica" on public.%I', t);
    execute format('create policy "lectura publica" on public.%I for select using (true)', t);
    execute format('drop policy if exists "escribe admin" on public.%I', t);
    execute format('create policy "escribe admin" on public.%I for all using (public.es_admin()) with check (public.es_admin())', t);
  end loop;
end $$;

-- ---- SOLICITUDES ----------------------------------------------------------
-- Cualquiera puede enviar el formulario; solo la Secretaría las lee.
drop policy if exists "cualquiera solicita" on public.solicitudes;
create policy "cualquiera solicita" on public.solicitudes
  for insert with check (true);

drop policy if exists "admin lee solicitudes" on public.solicitudes;
create policy "admin lee solicitudes" on public.solicitudes
  for all using (public.es_admin()) with check (public.es_admin());


-- ============================================================================
--  9. STORAGE (imágenes y PDF)
-- ============================================================================
insert into storage.buckets (id, name, public)
values ('web', 'web', true)
on conflict (id) do nothing;

drop policy if exists "lectura publica web" on storage.objects;
create policy "lectura publica web" on storage.objects
  for select using (bucket_id = 'web');

drop policy if exists "admin sube archivos" on storage.objects;
create policy "admin sube archivos" on storage.objects
  for all using (bucket_id = 'web' and public.es_admin())
  with check (bucket_id = 'web' and public.es_admin());


-- ============================================================================
--  10. CONTENIDO INICIAL
-- ============================================================================

insert into public.cultos (dia, mes, titulo, detalle, orden) values
  ('12','Julio','Misa de Hermandad','Primer viernes de mes · 20:30 h · Santuario de la Inmaculada', 1),
  ('15','Agosto','Solemne Función a la Santísima Virgen','12:00 h · Sede canónica', 2),
  ('26','Marzo','Cabildo General Extraordinario','19:00 h · Casa Hermandad', 3),
  ('02','Abril','Estación de Penitencia','Miércoles Santo · Salida procesional', 4)
on conflict do nothing;

insert into public.campanias (titulo, objetivo, recaudado, activa) values
  ('Restauración del paso de palio', 5000, 3200, true)
on conflict do nothing;


-- ============================================================================
--  ✅ LISTO. AHORA CREA EL USUARIO ADMINISTRADOR
--
--  PASO 1 — Crear el usuario en Authentication
--    Supabase → Authentication → Users → "Add user" → "Create new user"
--      Email:    secretaria@hermandadamargura.es
--      Password: (elige una segura y guárdala)
--      ✅ Marca "Auto Confirm User"
--    Copia el UUID que aparece en la columna "UID".
--
--  PASO 2 — Convertirlo en administrador
--    Vuelve al SQL Editor, pega esto sustituyendo el UUID y el email,
--    y pulsa RUN:
--
--      insert into public.hermanos
--        (user_id, num, nombre, email, rol, acceso, desde, debe_cambiar_password)
--      values
--        ('PEGA-AQUI-EL-UUID',
--         '001',
--         'Secretaría de la Hermandad',
--         'secretaria@hermandadamargura.es',
--         'admin',
--         true,
--         'Administrador',
--         false);
--
--  PASO 3 — Comprobar que ha funcionado
--      select num, nombre, rol from public.hermanos where rol = 'admin';
--    Debe devolver una fila. Ya puedes entrar en el portal con ese correo
--    y contraseña, y verás el Panel de Administración.
-- ============================================================================
