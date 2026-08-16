# Web Hermandad de la Amargura · La Línea de la Concepción

Sitio web y Portal del Hermano de la Real, Venerable y Sacramental Hermandad
de María Santísima de la Amargura.

## Archivos

| Archivo | Qué es |
|---|---|
| `index.html` | Web pública (inicio, historia, titulares, cultos, actualidad, contacto…) |
| `portal-hermano.html` | Portal del Hermano + Panel de Administración (Secretaría) |
| `support.js` | Runtime necesario para ambas páginas |
| `assets/` | Imágenes propias de la Hermandad |

## Publicar en Vercel

1. Sube este repositorio a GitHub.
2. En Vercel: **Add New → Project → Import** el repositorio.
3. Framework preset: **Other**. No hace falta build command ni output directory:
   es HTML estático.
4. Deploy.

### Dominio propio

En el proyecto de Vercel → **Settings → Domains** → añade `hermandadamargura.es`
y `www.hermandadamargura.es`.

Dos opciones en el registrador del dominio:

- **Nameservers de Vercel** (más simple, Vercel gestiona todo el DNS).
- **Solo registros DNS** (recomendado si el dominio ya tiene correo):
  - `A` de `@` → `76.76.21.21`
  - `CNAME` de `www` → `cname.vercel-dns.com`

⚠️ Si el dominio tiene correo (@hermandadamargura.es), **no cambies los
nameservers** sin copiar antes los registros MX.

El certificado HTTPS lo emite Vercel automáticamente.

## Accesos de demostración

En el Portal del Hermano hay dos accesos de prueba, sin contraseña:

- **Entrar como Hermano** → vista del hermano (cuotas, donativos, datos)
- **Entrar como Administrador** → panel de Secretaría

También por URL: `portal-hermano.html?modo=hermano` y `?modo=admin`.

> ⚠️ **Antes de publicar en producción hay que cerrar estos accesos de
> demostración** y sustituirlos por autenticación real.

## Estado actual

Todo el interfaz es funcional, pero **los datos viven solo en el navegador**:
al recargar se pierden y no se comparten entre ordenadores. Es una maqueta
funcional completa, pendiente de conectar el backend.

### Qué falta para producción

1. **Supabase**
   - Tablas: `hermanos`, `cuotas`, `donativos`, `paginas`, `noticias`,
     `cultos`, `boletines`, `fotos`
   - Storage para imágenes y PDF de boletines
   - Row Level Security: cada hermano solo ve sus datos
   - Auth con roles (`hermano` / `admin`)
2. **Login real** — hoy el acceso es de demostración
3. **Bizum** de empresa contratado con el banco de la Hermandad
4. **Envío de correo** (Resend, SendGrid…) para los comunicados
5. **Legal (obligatorio en España)** — política de privacidad y aviso legal
   RGPD: se guardan DNI e IBAN de los hermanos

El código lleva comentarios `TODO Supabase:` en cada punto donde entra el backend.

## Cobros

De momento **solo Bizum**. El circuito es semiautomático porque Bizum no tiene
webhook:

1. El hermano ve el número de Bizum y el importe exacto en su portal.
2. Pulsa «Ya he hecho el Bizum» → su recibo queda **En revisión**.
3. La Secretaría comprueba el ingreso en el banco y pulsa **✓ Pagado**.

El recibo **nunca** se marca como pagado por decisión del hermano.
