# Hermandad de la Amargura — sitio web

Sitio estático, sin build. Para publicarlo en GitHub Pages:

1. Sube todo el contenido de esta carpeta a la raíz de tu repositorio (o a una rama `main`).
2. En GitHub → Settings → Pages → Source: "Deploy from a branch" → rama `main`, carpeta `/root`.
3. Tu web quedará en `https://<usuario>.github.io/<repo>/`.

## Archivos
- `index.html` — web pública (inicio, hermandad, titulares, actualidad, contacto...)
- `portal-hermano.html` — Portal del Hermano (modo hermano y modo administrador, `?modo=hermano` / `?modo=admin`)
- `panel-admin.html` — panel de administración independiente (gestión de contenido, hermanos, cuotas, comunicados)
- `support.js` — motor de la plantilla, necesario para que carguen las 3 páginas

## Pendiente antes de producción real
- Conectar Supabase (datos de hermanos/cuotas/donativos ahora son de demostración y vuelven a su estado inicial al recargar).
- Login real (el acceso actual es una demo sin contraseña).
- Cuenta Stripe + Bizum para cobros reales.
- Envío de email real para los comunicados.
- Aviso legal y política de privacidad (RGPD, datos de hermanos).
