-- ============================================================================
--  PASAR LOS ACCESOS EXISTENTES AL DNI
--
--  Los accesos creados antes usaban el correo del hermano. Ahora el portal
--  funciona con el DNI, así que hay que convertirlos.
--
--  Deja a cada hermano con:
--      Usuario:    su DNI
--      Contraseña: su DNI
--
--  La cuenta de Secretaría NO se toca: sigue entrando con su correo.
--
--  CÓMO USARLO:  Supabase → SQL Editor → New query → pega esto → RUN
-- ============================================================================


-- ---------------------------------------------------------------------------
--  1. ¿Cómo están ahora los accesos?
-- ---------------------------------------------------------------------------
select
  h.num,
  h.nombre,
  h.dni,
  u.email as usuario_actual,
  h.rol
from public.hermanos h
join auth.users u on u.id = h.user_id
order by h.rol desc, h.num;


-- ---------------------------------------------------------------------------
--  2. Conversión
-- ---------------------------------------------------------------------------
do $$
declare
  r record;
  nuevo_login text;
  convertidos int := 0;
begin
  for r in
    select h.user_id, h.nombre, h.dni
      from public.hermanos h
     where h.rol <> 'admin'          -- la Secretaría se queda con su correo
       and h.user_id is not null
       and coalesce(h.dni, '') <> ''
  loop
    -- Identificador interno: <DNI>@hermandadamargura.es (el hermano solo teclea el DNI)
    nuevo_login := lower(regexp_replace(r.dni, '[^a-zA-Z0-9]', '', 'g'))
                   || '@hermandadamargura.es';

    -- ¿Ese login ya lo tiene otro usuario distinto?
    if exists (
      select 1 from auth.users
       where email = nuevo_login and id <> r.user_id
    ) then
      raise notice '⚠ % — el usuario % ya existe, lo salto', r.nombre, nuevo_login;
      continue;
    end if;

    update auth.users
       set email              = nuevo_login,
           encrypted_password = crypt(upper(trim(r.dni)), gen_salt('bf')),
           email_confirmed_at = coalesce(email_confirmed_at, now()),
           updated_at         = now()
     where id = r.user_id;

    -- La identidad del proveedor "email" debe apuntar al mismo sitio
    update auth.identities
       set identity_data = jsonb_set(
             jsonb_set(identity_data, '{email}', to_jsonb(nuevo_login)),
             '{email_verified}', 'true'::jsonb
           ),
           updated_at = now()
     where user_id = r.user_id and provider = 'email';

    convertidos := convertidos + 1;
    raise notice '✅ % → entra con su DNI %', r.nombre, upper(trim(r.dni));
  end loop;

  raise notice '--- % accesos convertidos ---', convertidos;
end $$;


-- ---------------------------------------------------------------------------
--  3. Comprobación final
-- ---------------------------------------------------------------------------
select
  h.num,
  h.nombre,
  upper(h.dni)  as usuario_y_contrasena,
  u.email       as identificador_interno,
  h.rol
from public.hermanos h
join auth.users u on u.id = h.user_id
order by h.rol desc, h.num;


-- ============================================================================
--  ✅ LISTO
--
--  Cada hermano entra ahora escribiendo su DNI en los dos campos.
--  Ejemplo:  usuario 77392405G  ·  contraseña 77392405G
--
--  La Secretaría sigue entrando con secretaria@hermandadamargura.es
-- ============================================================================
