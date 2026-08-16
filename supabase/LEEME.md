# Conectar Supabase · Hermandad de la Amargura

## Qué hay aquí

| Archivo | Qué hacer con él |
|---|---|
| `supabase-schema.sql` | Pegarlo entero en el SQL Editor de Supabase y pulsar RUN |
| `supabase-config.js` | **Aquí pones tus 2 claves** — va junto a index.html |
| `supabase-api.js` | No tocar. Todas las consultas a la base de datos |
| `functions/crear-hermano/index.ts` | Función de servidor para dar de alta hermanos |

---

## 1. Crear el proyecto

[supabase.com](https://supabase.com) → **New project**
- Nombre: `hermandad-amargura`
- Región: **West EU (Ireland)** (la más cercana a España)
- Guarda la contraseña de base de datos que te pida

## 2. Crear las tablas

**SQL Editor** → **New query** → pega todo `supabase-schema.sql` → **RUN**

## 3. Crear el usuario administrador

**3.1** Authentication → Users → **Add user** → *Create new user*
- Email: `secretaria@hermandadamargura.es`
- Password: la que elijas
- ✅ **Auto Confirm User**

Copia el **UID** que aparece.

**3.2** SQL Editor, cambiando el UUID por el tuyo:

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

**3.3** Comprobar que ha ido bien:

```sql
select num, nombre, rol from public.hermanos where rol = 'admin';
```

## 4. 🔑 DÓNDE VAN LAS CLAVES

En Supabase: **Settings → API**. Verás tres valores; solo necesitas dos:

| En Supabase | Va en |
|---|---|
| **Project URL** | `supabase-config.js` → `window.SUPABASE_URL` |
| **anon public** | `supabase-config.js` → `window.SUPABASE_ANON_KEY` |
| **service_role** | ❌ **En ningún sitio del navegador.** Solo la usan las Edge Functions, y la reciben automáticamente |

Abre `supabase-config.js` y rellena:

```js
window.SUPABASE_URL = 'https://xxxxxxxxxxxx.supabase.co';
window.SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIs...';
```

Guarda, sube el cambio a GitHub y Vercel lo despliega solo.

Con los campos vacíos la web sigue funcionando en modo demostración.

## 5. Función de alta de hermanos

```bash
npm i -g supabase
supabase login
supabase link --project-ref TU-REF-DE-PROYECTO
supabase functions deploy crear-hermano
```

Con esto, al dar de alta un hermano con DNI y correo:
- **Usuario:** su correo
- **Contraseña inicial:** su DNI
- Se le pide cambiarla al entrar
- Se le emite la cuota del año automáticamente
