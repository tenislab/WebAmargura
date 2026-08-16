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
| `supabase-schema.sql` | Script que crea todas las tablas, permisos y contenido inicial |
| `supabase/functions/crear-hermano/` | Función de servidor para dar de alta hermanos con acceso |
| `assets/` | Imágenes propias de la Hermandad |

---

# 1. Conectar Supabase

## Paso 1 · Crear el proyecto

1. Entra en [supabase.com](https://supabase.com) → **New project**
2. Nombre: `hermandad-amargura`
3. Región: **West EU (Ireland)** — la más cercana a España
4. Guarda bien la contraseña de la base de datos que te pida

## Paso 2 · Crear las tablas

1. Menú lateral → **SQL Editor** → **New query**
2. Abre `supabase-schema.sql`, copia **todo** el contenido y pégalo
3. Pulsa **RUN**

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

## Paso 3 · Crear el usuario administrador

**3.1 — Crear el usuario**

Supabase → **Authentication** → **Users** → **Add user** → *Create new user*

- Email: `secretaria@hermandadamargura.es`
- Password: elige una segura y guárdala
- ✅ Marca **Auto Confirm User**

Copia el **UID** que aparece en la lista.

**3.2 — Convertirlo en administrador**

SQL Editor → nueva consulta, sustituyendo el UUID:

```sql
insert into public.hermanos
  (user_id, num, nombre, email, rol, acceso, desde, debe_cambiar_password)
values
  ('PEGA-AQUI-EL-UUID',
   '001',
   'Secretaría de la Hermandad',
   'secretaria@hermandadamargura.es',
   'admin',
   true,
   'Administrador',
   false);
```

**3.3 — Comprobar**

```sql
select num, nombre, rol from public.hermanos where rol = 'admin';
```

Debe devolver una fila.

## Paso 4 · Poner las claves en la web

Supabase → **Settings** → **API**. Copia los dos valores en `supabase-config.js`:

```js
window.SUPABASE_URL = 'https://xxxxxxxxxxx.supabase.co';
window.SUPABASE_ANON_KEY = 'eyJhbGciOi...';
```

> La clave **anon public** puede ir ahí sin problema: es pública por diseño y
> está protegida por las políticas RLS.
> La clave **service_role** NUNCA debe aparecer en el navegador.

Con los campos vacíos la web sigue funcionando en **modo demostración**.

## Paso 5 · Función de alta de hermanos

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
