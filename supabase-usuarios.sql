-- ============================================================================
--  CREAR LAS DOS CUENTAS · Hermandad de la Amargura
--
--  Crea de una vez:
--    · Cuenta de ADMINISTRADOR (Secretaría)
--    · Cuenta de HERMANO de prueba, con sus cuotas y un donativo
--
--  CÓMO USARLO:
--    1. Supabase → SQL Editor → New query
--    2. Pega TODO este archivo
--    3. Pulsa RUN
--
--  ⚠️ IMPORTANTE: ejecuta ANTES el archivo supabase-schema.sql.
--     Si no existen las tablas, esto fallará.
--
--  ⚠️ Cambia las contraseñas de abajo antes de ejecutarlo si quieres otras.
-- ============================================================================


-- ============================================================================
--  DATOS DE ACCESO QUE SE VAN A CREAR
--
--   ADMINISTRADOR (Secretaría)
--     Correo:     secretaria@hermandadamargura.es
--     Contraseña: Amargura2026!
--
--   HERMANO DE PRUEBA
--     Correo:     hermano@hermandadamargura.es
--     Contraseña: Hermano2026!
--
--  Cambia estos valores aquí debajo si lo prefieres:
-- ============================================================================

do $$
declare
  -- ---- CAMBIA AQUÍ SI QUIERES OTRAS CREDENCIALES ----
  email_admin    text := 'secretaria@hermandadamargura.es';
  pass_admin     text := 'Amargura2026!';

  email_hermano  text := 'hermano@hermandadamargura.es';
  pass_hermano   text := 'Hermano2026!';
  -- ---------------------------------------------------

  uid_admin      uuid;
  uid_hermano    uuid;
  id_h_admin     uuid;
  id_h_hermano   uuid;
  anio           int := extract(year from current_date);
begin

  -- ==========================================================================
  --  1. USUARIO ADMINISTRADOR
  -- ==========================================================================

  select id into uid_admin from auth.users where email = email_admin;

  if uid_admin is null then
    uid_admin := gen_random_uuid();

    insert into auth.users (
      instance_id, id, aud, role, email, encrypted_password,
      email_confirmed_at, created_at, updated_at,
      raw_app_meta_data, raw_user_meta_data,
      confirmation_token, recovery_token, email_change_token_new, email_change
    ) values (
      '00000000-0000-0000-0000-000000000000',
      uid_admin, 'authenticated', 'authenticated',
      email_admin, crypt(pass_admin, gen_salt('bf')),
      now(), now(), now(),
      '{"provider":"email","providers":["email"]}'::jsonb,
      '{"nombre":"Secretaría de la Hermandad"}'::jsonb,
      '', '', '', ''
    );

    insert into auth.identities (
      provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
    ) values (
      uid_admin::text, uid_admin,
      json_build_object('sub', uid_admin::text, 'email', email_admin, 'email_verified', true)::jsonb,
      'email', now(), now(), now()
    );

    raise notice '✅ Usuario administrador creado: %', email_admin;
  else
    -- Si ya existía, le ponemos la contraseña indicada
    update auth.users
       set encrypted_password = crypt(pass_admin, gen_salt('bf')),
           email_confirmed_at = coalesce(email_confirmed_at, now())
     where id = uid_admin;
    raise notice 'ℹ️  El usuario % ya existía: contraseña actualizada', email_admin;
  end if;

  -- Ficha en el censo con rol de administrador
  insert into public.hermanos
    (user_id, num, nombre, email, dni, telefono, direccion,
     desde, rol, acceso, debe_cambiar_password)
  values
    (uid_admin, '001', 'Secretaría de la Hermandad', email_admin,
     '00000000A', '956 000 000', 'Calle Isabel la Católica, 34 · La Línea de la Concepción',
     'Administrador', 'admin', true, false)
  on conflict (num) do update
    set user_id = excluded.user_id,
        rol     = 'admin',
        acceso  = true
  returning id into id_h_admin;


  -- ==========================================================================
  --  2. USUARIO HERMANO DE PRUEBA
  -- ==========================================================================

  select id into uid_hermano from auth.users where email = email_hermano;

  if uid_hermano is null then
    uid_hermano := gen_random_uuid();

    insert into auth.users (
      instance_id, id, aud, role, email, encrypted_password,
      email_confirmed_at, created_at, updated_at,
      raw_app_meta_data, raw_user_meta_data,
      confirmation_token, recovery_token, email_change_token_new, email_change
    ) values (
      '00000000-0000-0000-0000-000000000000',
      uid_hermano, 'authenticated', 'authenticated',
      email_hermano, crypt(pass_hermano, gen_salt('bf')),
      now(), now(), now(),
      '{"provider":"email","providers":["email"]}'::jsonb,
      '{"nombre":"José María Ruiz Delgado"}'::jsonb,
      '', '', '', ''
    );

    insert into auth.identities (
      provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
    ) values (
      uid_hermano::text, uid_hermano,
      json_build_object('sub', uid_hermano::text, 'email', email_hermano, 'email_verified', true)::jsonb,
      'email', now(), now(), now()
    );

    raise notice '✅ Usuario hermano creado: %', email_hermano;
  else
    update auth.users
       set encrypted_password = crypt(pass_hermano, gen_salt('bf')),
           email_confirmed_at = coalesce(email_confirmed_at, now())
     where id = uid_hermano;
    raise notice 'ℹ️  El usuario % ya existía: contraseña actualizada', email_hermano;
  end if;

  insert into public.hermanos
    (user_id, num, nombre, email, dni, telefono, direccion, iban,
     desde, rol, acceso, debe_cambiar_password)
  values
    (uid_hermano, '428', 'José María Ruiz Delgado', email_hermano,
     '75318642B', '600 123 456', 'Calle Real, 12 · La Línea de la Concepción',
     'ES12 3456 7890 1234 5678 9012',
     'Desde 1998', 'hermano', true, false)
  on conflict (num) do update
    set user_id = excluded.user_id,
        acceso  = true
  returning id into id_h_hermano;


  -- ==========================================================================
  --  3. CUOTAS DEL HERMANO DE PRUEBA
  -- ==========================================================================

  delete from public.cuotas where hermano_id = id_h_hermano;

  insert into public.cuotas (hermano_id, concepto, detalle, importe, estado, metodo_pago, fecha_pago, ejercicio) values
    (id_h_hermano, 'Cuota anual ' || anio,       'Domiciliada · 31/01/' || anio,       30, 'Pagado',    'Domiciliación', make_date(anio, 1, 31),   anio),
    (id_h_hermano, 'Cuota anual ' || (anio - 1), 'Domiciliada · 31/01/' || (anio - 1), 30, 'Pagado',    'Domiciliación', make_date(anio-1, 1, 31), anio - 1),
    (id_h_hermano, 'Cuota anual ' || (anio - 2), 'Domiciliada · 31/01/' || (anio - 2), 28, 'Pagado',    'Domiciliación', make_date(anio-2, 1, 31), anio - 2),
    (id_h_hermano, 'Aportación Casa Hermandad',  'Extraordinaria · ' || anio,          20, 'Pendiente', null,            null,                     anio);

  -- Un donativo suyo, para que se vea en "Mis donativos"
  insert into public.donativos (hermano_id, nombre, concepto, importe, metodo, fecha)
  values (id_h_hermano, 'José María Ruiz Delgado', 'Donativo Cultos', 25, 'Bizum', current_date - 30);


  -- ==========================================================================
  --  4. ALGUNOS HERMANOS MÁS (sin acceso al portal, solo censo)
  -- ==========================================================================

  insert into public.hermanos (num, nombre, dni, desde, rol, acceso) values
    ('429', 'Ana Belén Corbacho Ruiz',  '44982103K', 'Desde 2001', 'hermano', false),
    ('430', 'Francisco Peña Montiel',   '31776540D', 'Desde 2010', 'hermano', false),
    ('431', 'María del Mar Gil Heatley','52014398T', 'Desde 2015', 'hermano', false),
    ('432', 'Rafael Valencia Ortega',   '28640175M', 'Desde 1989', 'hermano', false),
    ('433', 'Lucía Casasola Abad',      '49307821H', 'Desde 2020', 'hermano', false)
  on conflict (num) do nothing;

  -- Cuota del año a los que no la tengan
  insert into public.cuotas (hermano_id, concepto, detalle, importe, estado, ejercicio)
  select h.id, 'Cuota anual ' || anio, 'Pendiente de pago', 30, 'Pendiente', anio
    from public.hermanos h
   where h.num in ('429','430','431','432','433')
     and not exists (
       select 1 from public.cuotas c
        where c.hermano_id = h.id and c.ejercicio = anio
     );

  raise notice '✅ Todo listo.';

end $$;


-- ============================================================================
--  COMPROBACIÓN
-- ============================================================================

select num, nombre, rol, acceso, email
  from public.hermanos
 order by num;

select h.num, h.nombre, c.concepto, c.importe, c.estado
  from public.cuotas c
  join public.hermanos h on h.id = c.hermano_id
 order by h.num, c.id;


-- ============================================================================
--  ✅ YA PUEDES ENTRAR EN EL PORTAL
--
--   ADMINISTRADOR (Secretaría)
--     secretaria@hermandadamargura.es  /  Amargura2026!
--
--   HERMANO DE PRUEBA (nº 428, José María Ruiz Delgado)
--     hermano@hermandadamargura.es     /  Hermano2026!
--
--  El hermano verá 3 cuotas pagadas, 1 pendiente de 20 € y un donativo.
--  La Secretaría verá 6 hermanos y 6 recibos pendientes.
--
--  🔒 CAMBIA ESTAS CONTRASEÑAS antes de abrir la web al público,
--     y borra el hermano de prueba cuando importes el censo real:
--
--       delete from auth.users where email = 'hermano@hermandadamargura.es';
-- ============================================================================
