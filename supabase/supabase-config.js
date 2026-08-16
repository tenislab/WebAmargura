// ============================================================================
//  CONFIGURACIÓN DE SUPABASE
//  Rellena estos dos valores y el portal deja de ser una maqueta:
//  pasa a leer y escribir en la base de datos real.
//
//  Dónde encontrarlos:
//    Supabase → tu proyecto → Settings → API
//      · Project URL      -> SUPABASE_URL
//      · anon public key  -> SUPABASE_ANON_KEY
//
//  ⚠️ La clave "anon public" SÍ puede ir aquí: es pública por diseño y está
//     protegida por las políticas RLS del esquema. La clave "service_role"
//     NUNCA debe aparecer en el navegador.
//
//  Si los dejas vacíos, la web funciona en MODO DEMOSTRACIÓN con datos de
//  ejemplo en el navegador (lo que tienes ahora mismo).
// ============================================================================

window.SUPABASE_URL = '';
window.SUPABASE_ANON_KEY = '';
