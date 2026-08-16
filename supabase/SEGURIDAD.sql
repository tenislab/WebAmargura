-- ============================================================================
--  PARCHE DE SEGURIDAD · Hermandad de la Amargura
--
--  Corrige un fallo por el que un hermano podía convertirse en administrador
--  editando su propia ficha, y refuerza un par de puntos más.
--
--  CÓMO USARLO:
--    Supabase → SQL Editor → New query → pegar todo → RUN
--
--  Es seguro ejecutarlo varias veces.
-- ============================================================================


-- ============================================================================
--  1. ESCALADA DE PRIVILEGIOS  (importante)
--
--  La política de edición de la ficha comprobaba QUÉ FILA se tocaba, pero no
--  QUÉ VALORES se escribían. Un hermano con conocimientos podía lanzar
--
--      update hermanos set rol = 'admin' where user_id = auth.uid();
--
--  y pasar a ser administrador: ver el censo entero, los DNI, los IBAN y
--  marcar recibos como pagados.
--
--  Solución: la política vuelve a exigir que la fila siga siendo suya
--  (WITH CHECK) y, además, un disparador impide que nadie que no sea
--  administrador toque los campos delicados.
-- ============================================================================

drop policy if exists "hermano edita su ficha" on public.hermanos;
create policy "hermano edita su ficha" on public.hermanos
  for update
  using      (user_id = auth.uid() or public.es_admin())
  with check (user_id = auth.uid() or public.es_admin());


create or replace function public.protege_campos_hermano()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  -- La Secretaría puede cambiarlo todo
  if public.es_admin() then
    return new;
  end if;

  -- Un hermano solo puede cambiar sus datos de contacto.
  -- Cualquier intento de tocar estos campos se descarta en silencio.
  new.rol     := old.rol;
  new.user_id := old.user_id;
  new.num     := old.num;
  new.activo  := old.activo;
  new.acceso  := old.acceso;
  new.desde   := old.desde;

  return new;
end;
$$;

drop trigger if exists protege_campos_hermano on public.hermanos;
create trigger protege_campos_hermano
  before update on public.hermanos
  for each row execute function public.protege_campos_hermano();


-- ============================================================================
--  2. QUE NADIE SE CUELE EN EL CENSO
--
--  El registro de usuarios está abierto (hace falta para dar de alta a los
--  hermanos desde Secretaría). Una cuenta creada por su cuenta no ve nada,
--  porque no está enlazada a ninguna ficha... salvo que pudiera crearse la
--  ficha ella misma. Esto lo impide: solo la Secretaría da altas.
-- ============================================================================

drop policy if exists "solo admin da de alta" on public.hermanos;
create policy "solo admin da de alta" on public.hermanos
  for insert with check (public.es_admin());


-- ============================================================================
--  3. AVISOS DE PAGO POR BIZUM
--
--  Un hermano avisa de que ha pagado, pero no debe poder avisar en nombre
--  de otro ni, por supuesto, dar el recibo por cobrado.
-- ============================================================================

drop policy if exists "hermano avisa de su pago" on public.avisos_pago;
create policy "hermano avisa de su pago" on public.avisos_pago
  for insert with check (hermano_id = public.mi_hermano_id());

-- Nadie puede borrar ni alterar un aviso salvo la Secretaría
drop policy if exists "solo admin toca avisos" on public.avisos_pago;
create policy "solo admin toca avisos" on public.avisos_pago
  for all using (public.es_admin()) with check (public.es_admin());


-- ============================================================================
--  4. FORMULARIOS PÚBLICOS
--
--  Cualquiera puede enviar una solicitud (es un formulario público), pero
--  nadie puede leer las de los demás: solo la Secretaría.
-- ============================================================================

drop policy if exists "cualquiera solicita" on public.solicitudes;
create policy "cualquiera solicita" on public.solicitudes
  for insert with check (true);

drop policy if exists "admin lee solicitudes" on public.solicitudes;
create policy "admin lee solicitudes" on public.solicitudes
  for all using (public.es_admin()) with check (public.es_admin());


-- ============================================================================
--  COMPROBACIÓN
--  Debe aparecer 'protege_campos_hermano' y las políticas con qual y with_check
-- ============================================================================

select tgname as disparador
  from pg_trigger
 where tgrelid = 'public.hermanos'::regclass
   and not tgisinternal;

select tablename, policyname, cmd,
       (qual is not null)       as tiene_using,
       (with_check is not null) as tiene_with_check
  from pg_policies
 where schemaname = 'public'
   and tablename in ('hermanos','cuotas','donativos','avisos_pago','solicitudes')
 order by tablename, policyname;


-- ============================================================================
--  ✅ PARCHE APLICADO
--
--  Para comprobarlo tú mismo: entra como hermano y ejecuta desde el navegador
--
--      await window.API.sb.from('hermanos')
--        .update({ rol: 'admin' }).eq('user_id', (await window.API.sb.auth.getUser()).data.user.id);
--
--  Antes del parche, funcionaba. Ahora el rol se queda como estaba.
-- ============================================================================
