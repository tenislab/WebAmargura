-- ============================================================================
--  ¿Los cambios del panel no se guardan? Ejecuta esto.
--
--  Supabase no da error cuando rechaza una escritura por permisos:
--  simplemente no hace nada. Eso ocurre si tu cuenta no está enlazada
--  a una ficha con rol = 'admin' en la tabla "hermanos".
--
--  Supabase → SQL Editor → New query → pega esto → RUN
-- ============================================================================

-- 1. ¿Con qué cuenta has entrado y cómo está su ficha?
select
  u.email,
  h.num,
  h.nombre,
  h.rol,
  case when h.user_id is null then '❌ SIN ENLAZAR' else '✅ enlazada' end as enlace
from auth.users u
left join public.hermanos h on h.user_id = u.id
order by u.created_at;


-- 2. Arreglo: enlaza la cuenta con su ficha y la marca como administradora.
--    Cambia el correo si usas otro.
do $$
declare
  correo text := 'secretaria@hermandadamargura.es';
  uid uuid;
begin
  select id into uid from auth.users where email = correo;
  if uid is null then
    raise exception 'No existe ningún usuario con el correo %', correo;
  end if;

  -- ¿Ya hay una ficha para ese usuario?
  if exists (select 1 from public.hermanos where user_id = uid) then
    update public.hermanos set rol = 'admin', acceso = true where user_id = uid;
  elsif exists (select 1 from public.hermanos where email = correo) then
    update public.hermanos
       set user_id = uid, rol = 'admin', acceso = true
     where email = correo;
  else
    insert into public.hermanos (user_id, num, nombre, email, rol, acceso, desde)
    values (uid, '001', 'Secretaría de la Hermandad', correo, 'admin', true, 'Administrador');
  end if;

  raise notice '✅ % ya es administradora', correo;
end $$;


-- 3. Comprobación final
select u.email, h.num, h.nombre, h.rol
  from auth.users u
  join public.hermanos h on h.user_id = u.id
 where h.rol = 'admin';
