# Web Hermandad de la Amargura · La Línea de la Concepción

Sitio web y Portal del Hermano de la Real, Venerable y Sacramental Hermandad
de María Santísima de la Amargura.

## Archivos

| Archivo | Qué es |
|---|---|
| `index.html` | Web pública (inicio, historia, titulares, cultos, actualidad, contacto…) |
| `portal-hermano.html` | Portal del Hermano + Panel de Administración (Secretaría) |
| `support.js` | Runtime necesario para ambas páginas |
| `supabase-config.js` | **Aquí pones tus claves de Supabase** |
| `supabase-api.js` | Capa de datos: todas las consultas a la base de datos |
| `supabase-schema.sql` | **1º** — crea tablas, permisos y Storage |
| `supabase-usuarios.sql` | **2º** — crea las cuentas de administrador y hermano |
| `supabase-contenido.sql` | **3º** — vuelca los textos y fotos de la web |
| `vercel.json` | Configuración de despliegue y cabeceras de seguridad |
| `supabase/functions/crear-hermano/` | Función de servidor para dar de alta hermanos con acceso |
| `assets/` | Imágenes propias de la Hermandad |

---

# 1. Conectar Supabase


## 🔒 Seguridad — importante

Ejecuta **una vez** `supabase/SEGURIDAD.sql` en el SQL Editor.

Corrige una escalada de privilegios: la política de edición comprobaba qué
fila se tocaba pero no qué valores se escribían, así que un hermano podía
hacerse administrador editando su propia ficha. El parche añade el
`WITH CHECK` que faltaba y un disparador que protege los campos delicados
(rol, número de hermano, alta y baja).

Antes de abrir la web al público:

- [ ] Ejecutar `supabase/SEGURIDAD.sql`
- [ ] Cambiar las dos contraseñas por defecto
- [ ] Borrar el hermano de prueba
- [ ] Revisar los textos con la Junta de Gobierno

La clave `anon` que aparece en el HTML es pública por diseño: no da acceso a
nada por sí sola, todo lo protegen las políticas RLS. La clave `service_role`
**nunca** debe aparecer en el navegador.

## Paso 1 · Crear el proyecto

1. Entra en [supabase.com](https://supabase.com) → **New project**
2. Nombre: `hermandad-amargura`
3. Región: **West EU (Ireland)** — la más cercana a España
4. Guarda bien la contraseña de la base de datos que te pida

## Paso 2 · Crear las tablas y los datos

En **SQL Editor → New query**, ejecuta estos tres archivos **en este orden**:

| Orden | Archivo | Qué hace |
|---|---|---|
| 1 | `supabase-schema.sql` | Crea las 12 tablas, los permisos (RLS) y el Storage |
| 2 | `supabase-usuarios.sql` | Crea la cuenta de administrador y una de hermano de prueba |
| 3 | `supabase-contenido.sql` | Vuelca todos los textos y fotos de la web |

Al final del tercero verás un recuento para comprobar que ha entrado todo:
páginas 8 · noticias 6 · cultos 4 · boletines 4 · fotos 5 · hermanos 7 · cuotas 10.

### Cuentas que se crean

| | Correo | Contraseña |
|---|---|---|
| **Secretaría** | `secretaria@hermandadamargura.es` | `Amargura2026!` |
| **Hermano de prueba** | `hermano@hermandadamargura.es` | `Hermano2026!` |

> 🔒 Cambia estas contraseñas antes de abrir la web al público.

Esto crea de una vez:

**Tablas de gestión**
- `hermanos` — el censo, con rol (`hermano` / `admin`) y acceso al portal
- `cuotas` — recibos, fuente única para el hermano y la Secretaría
- `donativos` — aportaciones puntuales, enlazadas o no a un hermano
- `campanias` — recaudaciones con objetivo y barra de progreso
- `avisos_pago` — el hermano avisa del Bizum (no confirma el pago)
- `solicitudes` — formularios de «Hazte hermano», Grupo Joven y contacto

**Tablas de contenido web**
- `paginas` — texto y fotos de cada página fija
- `noticias` — Actualidad
- `cultos` — agenda de cultos y actos
- `boletines` — PDF de los boletines
- `fotos_portada` — imágenes rotatorias de la cabecera
- `ajustes` — número de Bizum y otros valores sueltos

También activa **Row Level Security**: cada hermano solo puede ver sus propios
datos, y solo la Secretaría puede cobrar recibos o editar la web. No depende
del navegador: lo impone la base de datos.

## Paso 3 · Poner las claves en la web

Supabase → **Settings** → **API**. Copia los dos valores en `supabase-config.js`:

```js
window.SUPABASE_URL = 'https://xxxxxxxxxxx.supabase.co';
window.SUPABASE_ANON_KEY = 'eyJhbGciOi...';
```

> La clave **anon public** puede ir ahí sin problema: es pública por diseño y
> está protegida por las políticas RLS.
> La clave **service_role** NUNCA debe aparecer en el navegador.

Con los campos vacíos la web sigue funcionando en **modo demostración**.

## Paso 4 · Función de alta de hermanos

Dar de alta un hermano crea también su usuario, y eso requiere la clave
`service_role`, que no puede estar en el navegador. Por eso va en una función
de servidor:

```bash
npm i -g supabase
supabase login
supabase link --project-ref TU-REF-DE-PROYECTO
supabase functions deploy crear-hermano
```

Al dar de alta un hermano con DNI y correo, el sistema crea su acceso:

- **Usuario:** su correo electrónico
- **Contraseña inicial:** su DNI
- Se le pide cambiarla en el primer acceso
- Se le emite automáticamente la cuota del año en curso

---

# 2. Publicar en Vercel

1. Sube este repositorio a GitHub
2. Vercel → **Add New → Project → Import** el repositorio
3. Framework preset: **Other**. Sin build command ni output directory: es HTML estático
4. Deploy

## Dominio propio

Vercel → **Settings → Domains** → añade `hermandadamargura.es` y
`www.hermandadamargura.es`. Dos opciones en el registrador:

- **Nameservers de Vercel** — más simple, Vercel gestiona todo el DNS
- **Solo registros DNS** — recomendado si el dominio ya tiene correo:
  - `A` de `@` → `76.76.21.21`
  - `CNAME` de `www` → `cname.vercel-dns.com`

> ⚠️ Si el dominio tiene correo (@hermandadamargura.es), **no cambies los
> nameservers** sin copiar antes los registros MX: se caería el email.

El certificado HTTPS lo emite Vercel automáticamente.

---

# 3. Cómo funcionan los cobros

De momento **solo Bizum**. Como Bizum no tiene confirmación automática
(no hay webhook), el circuito es semiautomático:

1. El hermano ve el número de Bizum y el importe exacto en su portal
2. Pulsa «Ya he hecho el Bizum» → su recibo queda **En revisión**
3. La Secretaría comprueba el ingreso en el banco y pulsa **✓ Pagado**

El recibo **nunca** se marca como pagado por decisión del hermano: la base de
datos lo impide, no solo la interfaz.

También se pueden registrar pagos por **domiciliación SEPA** y **efectivo en
la Casa Hermandad** desde el panel de Secretaría.

---

# 4. Antes de abrir al público

- [ ] Cerrar los accesos de demostración del portal (los botones «Entrar como
      Hermano / Administrador» y los parámetros `?modo=`)
- [ ] Contratar **Bizum de empresa** con el banco de la Hermandad
- [ ] Servicio de envío de correo (Resend, SendGrid…) para los comunicados
- [ ] **Política de privacidad y aviso legal RGPD** — obligatorio: se guardan
      DNI e IBAN de los hermanos
- [ ] Revisar con la Junta todos los textos y fotos
- [ ] Importar el censo real de hermanos

---

# 5. Estado del código

Toda la interfaz está terminada y es funcional. Los puntos donde entra la base
de datos están marcados en el código con comentarios `TODO Supabase:`, y las
consultas correspondientes ya están escritas en `supabase-api.js`.
