// ============================================================================
//  EDGE FUNCTION: crear-hermano
//  Da de alta un hermano Y le crea su acceso al portal en un solo paso.
//  Usuario = su correo · Contraseña inicial = su DNI
//
//  Existe porque crear usuarios requiere la clave `service_role`, que NUNCA
//  puede estar en el navegador. Aquí sí: se ejecuta en el servidor de Supabase.
//
//  CÓMO INSTALARLA
//    1. Instala la CLI:      npm i -g supabase
//    2. Inicia sesión:       supabase login
//    3. Enlaza el proyecto:  supabase link --project-ref TU-REF-DE-PROYECTO
//    4. Crea la carpeta:     supabase/functions/crear-hermano/index.ts
//                            (pega este archivo ahí)
//    5. Publícala:           supabase functions deploy crear-hermano
//
//  La variable SUPABASE_SERVICE_ROLE_KEY ya viene puesta automáticamente
//  en el entorno de las Edge Functions: no hay que configurar nada.
// ============================================================================

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors });

  try {
    const admin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    );

    // --- 1. Comprobar que quien llama es administrador ----------------------
    const token = (req.headers.get('Authorization') || '').replace('Bearer ', '');
    const { data: { user } } = await admin.auth.getUser(token);
    if (!user) {
      return new Response(JSON.stringify({ error: 'No autenticado' }), {
        status: 401, headers: { ...cors, 'Content-Type': 'application/json' },
      });
    }

    const { data: quienLlama } = await admin
      .from('hermanos').select('rol').eq('user_id', user.id).single();

    if (!quienLlama || quienLlama.rol !== 'admin') {
      return new Response(JSON.stringify({ error: 'Solo la Secretaría puede dar de alta hermanos' }), {
        status: 403, headers: { ...cors, 'Content-Type': 'application/json' },
      });
    }

    // --- 2. Datos del nuevo hermano ----------------------------------------
    const { nombre, num, dni, email, telefono, direccion } = await req.json();

    if (!nombre || !num) {
      return new Response(JSON.stringify({ error: 'Faltan el nombre o el número de hermano' }), {
        status: 400, headers: { ...cors, 'Content-Type': 'application/json' },
      });
    }

    const dniLimpio = String(dni || '').toUpperCase().trim();
    let userId = null;

    // --- 3. Crear su acceso al portal (contraseña inicial = DNI) ------------
    if (email && dniLimpio) {
      if (dniLimpio.length < 6) {
        return new Response(JSON.stringify({ error: 'El DNI debe tener al menos 6 caracteres para usarlo como contraseña' }), {
          status: 400, headers: { ...cors, 'Content-Type': 'application/json' },
        });
      }

      const { data: nuevo, error: errUser } = await admin.auth.admin.createUser({
        email,
        password: dniLimpio,
        email_confirm: true,
        user_metadata: { nombre, num_hermano: num },
      });
      if (errUser) throw errUser;
      userId = nuevo.user.id;
    }

    // --- 4. Guardarlo en el censo ------------------------------------------
    const { data: hermano, error: errHermano } = await admin.from('hermanos').insert({
      user_id: userId,
      num, nombre, dni: dniLimpio, email, telefono, direccion,
      desde: 'Alta ' + new Date().getFullYear(),
      rol: 'hermano',
      acceso: !!userId,
      debe_cambiar_password: true,
    }).select().single();
    if (errHermano) throw errHermano;

    // --- 5. Emitirle su cuota del año --------------------------------------
    const anio = new Date().getFullYear();
    await admin.from('cuotas').insert({
      hermano_id: hermano.id,
      concepto: 'Cuota anual ' + anio,
      importe: 30,
      ejercicio: anio,
      detalle: 'Pendiente de pago',
    });

    return new Response(JSON.stringify({
      hermano,
      usuario: email || null,
      password_inicial: userId ? dniLimpio : null,
      aviso: userId ? null : 'Sin correo o sin DNI no se ha creado acceso al portal.',
    }), { headers: { ...cors, 'Content-Type': 'application/json' } });

  } catch (e) {
    return new Response(JSON.stringify({ error: String(e.message || e) }), {
      status: 400, headers: { ...cors, 'Content-Type': 'application/json' },
    });
  }
});
