// ============================================================================
//  CAPA DE DATOS · Hermandad de la Amargura
//  Traduce todo lo que hace el portal a consultas de Supabase.
//
//  Se carga así (ya está puesto en portal-hermano.html e index.html):
//    <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
//    <script src="supabase-config.js"></script>
//    <script src="supabase-api.js"></script>
//
//  Si supabase-config.js está vacío, `window.API.activo` es false y la web
//  sigue funcionando con los datos de demostración.
// ============================================================================

(function () {
  // La URL debe ser la raíz del proyecto, sin /rest/v1 ni barra final.
  const URL_ = String(window.SUPABASE_URL || '').trim().replace(/\/rest\/v1\/?$/, '').replace(/\/+$/, '');
  const KEY_ = String(window.SUPABASE_ANON_KEY || '').trim();

  // Con URL y clave rellenas ya estamos "conectados": si la librería de
  // Supabase todavía no ha llegado (CDN lenta o bloqueada), se carga sola.
  const activo = !!(URL_ && KEY_);

  let sb = null;

  function cargarSDK() {
    if (window.supabase && window.supabase.createClient) return Promise.resolve();
    return new Promise((resolve, reject) => {
      const s = document.createElement('script');
      s.src = 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2';
      s.onload = () => resolve();
      s.onerror = () => reject(new Error('No se ha podido cargar la librería de Supabase.'));
      document.head.appendChild(s);
    });
  }

  const listo = !activo ? Promise.resolve(false) : cargarSDK()
    .then(() => { sb = window.supabase.createClient(URL_, KEY_); return true; })
    .catch(err => { console.error('[Amargura]', err); return false; });

  // Fecha en formato español para los detalles de recibo
  const hoy = () => new Date().toLocaleDateString('es-ES');
  const eur = (n) => Number(n).toFixed(2).replace('.', ',') + ' €';

  const API = {
    activo,
    sb,

    // ---------------------------------------------------------------- SESIÓN
    async login(email, password) {
      const { data, error } = await sb.auth.signInWithPassword({ email, password });
      if (error) throw error;
      return data;
    },

    async logout() {
      try { await sb.auth.signOut(); } catch (e) { console.warn(e); }
      try {
        // Limpia cualquier resto de sesión guardado por el SDK
        Object.keys(localStorage)
          .filter(k => k.startsWith('sb-') && k.includes('auth-token'))
          .forEach(k => localStorage.removeItem(k));
      } catch (e) {}
    },

    // Devuelve la ficha del hermano conectado, con su rol
    async yo() {
      const { data: { user } } = await sb.auth.getUser();
      if (!user) return null;
      const { data, error } = await sb
        .from('hermanos')
        .select('*')
        .eq('user_id', user.id)
        .maybeSingle();
      if (error) throw error;
      return data; // null si el usuario no está en el censo
    },

    async cambiarPassword(nueva) {
      const { error } = await sb.auth.updateUser({ password: nueva });
      if (error) throw error;
      // Ya no hace falta forzar el cambio la próxima vez
      const yo = await API.yo();
      if (yo) await sb.from('hermanos').update({ debe_cambiar_password: false }).eq('id', yo.id);
    },

    // ---------------------------------------------------------------- CENSO
    async censo() {
      const { data, error } = await sb
        .from('hermanos')
        .select('*')
        .eq('activo', true)
        .order('num');
      if (error) throw error;
      return data;
    },

    // Alta de hermano + su acceso al portal (usuario y contraseña = DNI).
    // OJO: crear usuarios de Auth desde el navegador requiere la clave
    // service_role, que NO puede estar aquí. Por eso esto llama a una Edge
    // Function `crear-hermano` que sí la tiene (ver README).
    async altaHermano({ nombre, num, dni, email }) {
      const { data, error } = await sb.functions.invoke('crear-hermano', {
        body: { nombre, num, dni, email },
      });
      if (error) throw error;
      return data; // { hermano, usuario, password_inicial }
    },

    async crearAcceso(hermanoId) {
      const { data, error } = await sb.functions.invoke('crear-acceso', {
        body: { hermano_id: hermanoId },
      });
      if (error) throw error;
      return data;
    },

    async guardarDatosHermano(id, campos) {
      const { error } = await sb.from('hermanos').update(campos).eq('id', id);
      if (error) throw error;
    },

    async bajaHermano(id) {
      const { error } = await sb.from('hermanos').update({ activo: false }).eq('id', id);
      if (error) throw error;
    },

    // ---------------------------------------------------------------- CUOTAS
    // Todas las cuotas visibles para quien pregunta:
    //  · un hermano recibe solo las suyas (lo impone RLS, no el cliente)
    //  · la Secretaría las recibe todas, con el nombre del hermano
    async cuotas() {
      const { data, error } = await sb
        .from('cuotas')
        .select('*, hermanos!inner(num, nombre, activo)')
        .eq('hermanos.activo', true)   // un hermano de baja no arrastra recibos
        .order('id');
      if (error) throw error;
      return data.map(c => ({
        id: c.id,
        hermanoNum: c.hermanos ? c.hermanos.num : null,
        nombre: c.hermanos ? c.hermanos.nombre : '',
        concepto: c.concepto,
        detalle: c.detalle,
        importe: eur(c.importe),
        estado: c.estado,
        avisado: c.avisado,
      }));
    },

    async emitirCuota({ hermanoId, concepto, importe, ejercicio }) {
      const { error } = await sb.from('cuotas').insert({
        hermano_id: hermanoId,
        concepto,
        importe,
        ejercicio,
        detalle: 'Pendiente de pago',
      });
      if (error) throw error;
    },

    // SOLO la Secretaría. RLS bloquea que un hermano llame a esto.
    async marcarPagado(cuotaId, metodo) {
      const { error } = await sb.from('cuotas').update({
        estado: 'Pagado',
        avisado: false,
        metodo_pago: metodo,
        fecha_pago: new Date().toISOString().slice(0, 10),
        detalle: metodo + ' · ' + hoy(),
      }).eq('id', cuotaId);
      if (error) throw error;
    },

    async marcarPendiente(cuotaId) {
      const { error } = await sb.from('cuotas').update({
        estado: 'Pendiente', avisado: false, metodo_pago: null,
        fecha_pago: null, detalle: 'Pendiente de pago',
      }).eq('id', cuotaId);
      if (error) throw error;
    },

    // El hermano avisa de que ha hecho el Bizum. NO marca pagado:
    // solo deja constancia para que la Secretaría lo confirme.
    async avisarBizum(cuotaId, hermanoId) {
      const { error } = await sb.from('avisos_pago').insert({
        cuota_id: cuotaId, hermano_id: hermanoId,
      });
      if (error) throw error;
    },

    // -------------------------------------------------------------- DONATIVOS
    async donativos() {
      const { data, error } = await sb
        .from('donativos')
        .select('*, hermanos(num, nombre)')
        .order('fecha', { ascending: false });
      if (error) throw error;
      return data.map(d => ({
        id: d.id,
        nombre: d.nombre,
        hermanoNum: d.hermanos ? d.hermanos.num : null,
        concepto: d.concepto,
        importe: eur(d.importe),
        metodo: d.metodo,
        fecha: new Date(d.fecha).toLocaleDateString('es-ES'),
      }));
    },

    async addDonativo({ nombre, hermanoId, concepto, importe, metodo }) {
      const { error } = await sb.from('donativos').insert({
        nombre, hermano_id: hermanoId || null, concepto, importe, metodo,
      });
      if (error) throw error;
    },

    async quitarDonativo(id) {
      const { error } = await sb.from('donativos').delete().eq('id', id);
      if (error) throw error;
    },

    // --------------------------------------------------------------- CAMPAÑA
    async campaniaActiva() {
      const { data, error } = await sb
        .from('campanias').select('*').eq('activa', true).limit(1).single();
      if (error) return null;
      return data;
    },

    async guardarCampania(id, campos) {
      const { error } = await sb.from('campanias').update(campos).eq('id', id);
      if (error) throw error;
    },

    // ------------------------------------------------------- CONTENIDO WEB
    async paginas() {
      const { data, error } = await sb.from('paginas').select('*').order('orden');
      if (error) throw error;
      return data;
    },

    async guardarPagina(id, campos) {
      const { error } = await sb.from('paginas')
        .update({ ...campos, updated_at: new Date().toISOString() })
        .eq('id', id);
      if (error) throw error;
    },

    async noticias({ soloPublicadas = false } = {}) {
      let q = sb.from('noticias').select('*').order('id', { ascending: false });
      if (soloPublicadas) q = q.eq('estado', 'Publicada');
      const { data, error } = await q;
      if (error) throw error;
      return data;
    },

    async guardarNoticia(id, campos) {
      if (id) {
        const { error } = await sb.from('noticias').update(campos).eq('id', id);
        if (error) throw error;
      } else {
        const { error } = await sb.from('noticias').insert(campos);
        if (error) throw error;
      }
    },

    async quitarNoticia(id) {
      const { error } = await sb.from('noticias').delete().eq('id', id);
      if (error) throw error;
    },

    async cultos() {
      const { data, error } = await sb.from('cultos').select('*').order('orden');
      if (error) throw error;
      return data;
    },

    async guardarCulto(id, campos) {
      if (id) {
        const { error } = await sb.from('cultos').update(campos).eq('id', id);
        if (error) throw error;
      } else {
        const { error } = await sb.from('cultos').insert(campos);
        if (error) throw error;
      }
    },

    async quitarCulto(id) {
      const { error } = await sb.from('cultos').delete().eq('id', id);
      if (error) throw error;
    },

    async boletines() {
      const { data, error } = await sb.from('boletines').select('*').order('orden');
      if (error) throw error;
      return data;
    },

    async fotosPortada() {
      const { data, error } = await sb.from('fotos_portada').select('*').order('orden');
      if (error) throw error;
      return data.map(f => f.url);
    },

    // ---------------------------------------------------------------- FICHEROS
    // Sube una imagen o PDF al bucket 'web' y devuelve su URL pública.
    async subirArchivo(file, carpeta = 'general') {
      const nombre = `${carpeta}/${Date.now()}-${file.name.replace(/[^\w.\-]/g, '_')}`;
      const { error } = await sb.storage.from('web').upload(nombre, file, { upsert: false });
      if (error) throw error;
      const { data } = sb.storage.from('web').getPublicUrl(nombre);
      return data.publicUrl;
    },

    // ---------------------------------------------------------------- AJUSTES
    async ajuste(clave) {
      const { data } = await sb.from('ajustes').select('valor').eq('clave', clave).single();
      return data ? data.valor : null;
    },

    async guardarAjuste(clave, valor) {
      const { error } = await sb.from('ajustes').upsert({ clave, valor });
      if (error) throw error;
    },

    // ------------------------------------------------------------ SOLICITUDES
    // Formularios públicos de la web (hazte hermano, grupo joven, contacto)
    async enviarSolicitud(datos) {
      const { error } = await sb.from('solicitudes').insert(datos);
      if (error) throw error;
    },

    async solicitudes() {
      const { data, error } = await sb.from('solicitudes')
        .select('*').order('created_at', { ascending: false });
      if (error) throw error;
      return data;
    },
  };

  // Cada método espera a que el cliente esté creado antes de ejecutarse.
  const APIListo = {};
  Object.keys(API).forEach(k => {
    const v = API[k];
    APIListo[k] = (typeof v === 'function')
      ? function () { const args = arguments; return listo.then(() => v.apply(API, args)); }
      : v;
  });
  Object.defineProperty(APIListo, 'sb', { get: () => sb });
  APIListo.activo = activo;
  APIListo.listo = listo;

  window.API = APIListo;

  if (!activo) {
    console.info(
      '%c[Amargura] Modo demostración: sin Supabase configurado.',
      'color:#A8843C;font-weight:bold',
      '\nRellena supabase-config.js para conectar la base de datos real.'
    );
  }
})();
