-- ============================================================================
--  CONTENIDO INICIAL DE LA WEB · Hermandad de la Amargura
--
--  Vuelca en la base de datos todos los textos y fotos que hoy tiene la web,
--  para que la Secretaría pueda editarlos desde el panel.
--
--  CÓMO USARLO:
--    1. Supabase → SQL Editor → New query
--    2. Pega TODO este archivo y pulsa RUN
--
--  ⚠️ Ejecuta ANTES:  supabase-schema.sql  y  supabase-usuarios.sql
--
--  Se puede volver a ejecutar sin miedo: actualiza en vez de duplicar.
-- ============================================================================


-- ============================================================================
--  1. PÁGINAS FIJAS (Titulares, Historia, Junta, Sede, Casa, Heráldica…)
--     bloques = [{ subtitulo, texto }]   ·   fotos = ["url", ...]
-- ============================================================================

insert into public.paginas (slug, icono, nombre, antetitulo, titulo, entradilla, bloques, fotos, orden) values (
  'titulares', '✝️', 'Sagrados Titulares', 'La Hermandad', 'Sagrados Titulares', 'Santísimo Cristo de la Misericordia, María Santísima de la Amargura y Jesús Sacramentado.',
  '[{"subtitulo":"Santísimo Cristo de la Misericordia","texto":"La imagen fue realizada en 1959 en los Talleres Salesianos de la Santísima Trinidad, en Sevilla, obra del insigne imaginero catalán José María Geronés y su círculo. Tallada en madera de cedro, representa al Redentor ya muerto, clavado en la cruz por tres clavos, con las piernas flexionadas y la cabeza girada levemente hacia la derecha."},{"subtitulo":"","texto":"Se encuadra en el estilo barroco andaluz con marcada tendencia manierista, de rasgos suaves y sin exageración gestual. El rostro, de expresión serena, transmite la impresión de haber exhalado su último aliento. Carente de rasgos excesivamente marcados, inspira serenidad y ternura."},{"subtitulo":"","texto":"La cruz arbórea original, dañada por xilófagos, fue sustituida en los años 70 por una lisa, y en la restauración de 2008 se le restituyó una cruz similar a la primitiva. La imagen obtuvo el beneplácito del tribunal el 3 de septiembre de 1960, siendo padrino de su bendición el torero don Carlos Corbacho."},{"subtitulo":"María Santísima de la Amargura","texto":"En 1956 la Junta de Gobierno encargó la talla al prestigioso imaginero sevillano D. Manuel Pineda Calderón. Sobre madera de ciprés de Flandes, el maestro logró conjugar en el rostro de Nuestra Señora el sufrimiento y la ternura, el dolor y la belleza. Su semblante conmovió tanto al autor que llegó a ofrecer tallar otra imagen para quedarse con esta."},{"subtitulo":"","texto":"De estructura de candelero, con torsión de cabeza y tronco hacia la derecha, fue concebida para un Calvario junto a San Juan. Se inscribe con plena fidelidad en los cánones del más puro barroco andaluz de Pineda Calderón."},{"subtitulo":"","texto":"Tras el incendio de febrero de 1974, fue restaurada por el propio autor —su última obra, pues falleció aquel diciembre—. Obtuvo el beneplácito del Tribunal de Arte Religioso el 3 de agosto de 1956 y fue bendecida el 30 de septiembre del mismo año."},{"subtitulo":"Jesús Sacramentado","texto":"Primer y más importante titular de nuestra corporación. La devoción se remonta al 15 de febrero de 1955, cuando un grupo de miembros de la Adoración Nocturna inició los trámites para constituir la Cofradía, dedicada a rendir cultos y honores al Santísimo Sacramento. La Hermandad celebra sus cultos realizando un altar sacramental cada vez que este procesiona por las calles de nuestra feligresía."}]'::jsonb,
  '["https://hermandadamargura.es/images/1024/16917111/IMG-20160128-WA0001_Original-M4UCvUmwP9swcc0izOWZxg.JPG","https://hermandadamargura.es/images/872/16995418/VirgenAmargura-Ukbvn4YNOhOBJBgmdlscTg.jpg"]'::jsonb,
  1
) on conflict (slug) do update set
  icono = excluded.icono, nombre = excluded.nombre, antetitulo = excluded.antetitulo,
  titulo = excluded.titulo, entradilla = excluded.entradilla,
  bloques = excluded.bloques, fotos = excluded.fotos, orden = excluded.orden;

insert into public.paginas (slug, icono, nombre, antetitulo, titulo, entradilla, bloques, fotos, orden) values (
  'historia', '📜', 'Historia', 'La Hermandad', 'Historia', 'Corporación fundada el 15 de febrero de 1955 en el Santuario de la Inmaculada Concepción.',
  '[{"subtitulo":"Fundación y primeros pasos","texto":"La fundación de nuestra Corporación se remonta al 15 de febrero de 1955, cuando, a través de un grupo de personas miembros de la Adoración Nocturna, se inician los trámites necesarios para constituir la Cofradía, dedicada a rendir cultos y honores al Santísimo Sacramento y veneración a la Santísima Virgen en su advocación de la Amargura."},{"subtitulo":"","texto":"Ante la insistencia del que sería nuestro primer Hermano Mayor, D. Juan Macías López, se formó una Junta Gestora que, alentada por el párroco de la Inmaculada, inició la andadura de nuestra Hermandad, con el apoyo de destacadas personalidades de la sociedad linense, entre ellas el Maestro D. Rafael Jaén."},{"subtitulo":"","texto":"La primera imagen de María Santísima de la Amargura fue cedida por la familia del Dr. Gabaldón, realizando en la Semana Santa de 1956 su primera Salida Procesional en una pequeña parihuela. El 30 de septiembre de 1956 fue bendecida la nueva imagen titular, obra del imaginero de Alcalá de Guadaíra D. Manuel Pineda Calderón, donación de Don Gregorio Meneses Plasencia."},{"subtitulo":"","texto":"Nuestra Corporación consiguió el título de Real el 8 de noviembre de 1956, cuando los Condes de Barcelona, SS. AA. RR. Don Juan de Borbón y Doña María de las Mercedes, concedieron a la Entidad el título de Real y las Armas de la Corona. En 1957 la Virgen fue coronada solemnemente, y en mayo de 1959 se adquirió el título de Sacramental."},{"subtitulo":"","texto":"En 1960 se incorporó la imagen del Santísimo Cristo de la Misericordia, obra del escultor D. José María Geronés, de los Talleres Salesianos de Arte Sacro de Sevilla, que hoy procesiona portado a hombros por nuestros hermanos."},{"subtitulo":"","texto":"El 14 de febrero de 1974, un incendio fortuito provocó graves daños en la imagen de la Virgen, que fue restaurada en Sevilla por su propio autor, D. Manuel Pineda Calderón. Aquel año solo procesionó el Santísimo Cristo de la Misericordia."},{"subtitulo":"Cincuentenario y tiempos recientes","texto":"Durante 2005 y 2006 se conmemoró el cincuentenario fundacional (1955–2005) con pregón, conferencias, cultos solemnes, nueva corona para la Virgen y salida extraordinaria en su paso de palio. El 8 de enero de 2010 se creó oficialmente el Grupo Joven, y ese año se conmemoró el 50 aniversario de la bendición del Cristo."},{"subtitulo":"","texto":"En 2013 se presentó el boceto del nuevo paso barroco, obra del tallista sevillano Don José Antonio García Flores, estrenado en su primera fase el Viernes Santo de 2014. El 7 de noviembre de 2014 se bendijo e inauguró la Casa Hermandad, en la Calle Isabel la Católica, 34."},{"subtitulo":"","texto":"El 15 de febrero de 2025 se cumplió el 70 aniversario fundacional de la Corporación. Ese mismo año se presentó una nueva saya para la Virgen, realizada a partir de un repostero del siglo XIX, restaurada por D. Ramón Fernández Ruiz y donada por N. H. D. Juan Manuel Guzmán Fernández."},{"subtitulo":"La Virgen de la Amargura, vulgo «de los Toreros»","texto":"Desde nuestros orígenes, la Hermandad ha estado muy unida al mundo del toreo, de ahí que se nos conozca como la «Hermandad de los Toreros». Han sido hermanos la Peña Taurina Joselito Manolete y los matadores linenses D. Carlos Corbacho, D. Rafael Valencia, D. Juan Carlos Landrove, D. Carlos Pacheco y D. Luis Miguel Arenillas."}]'::jsonb,
  '["https://hermandadamargura.es/images/872/16995418/VirgenAmargura-Ukbvn4YNOhOBJBgmdlscTg.jpg"]'::jsonb,
  2
) on conflict (slug) do update set
  icono = excluded.icono, nombre = excluded.nombre, antetitulo = excluded.antetitulo,
  titulo = excluded.titulo, entradilla = excluded.entradilla,
  bloques = excluded.bloques, fotos = excluded.fotos, orden = excluded.orden;

insert into public.paginas (slug, icono, nombre, antetitulo, titulo, entradilla, bloques, fotos, orden) values (
  'junta', '⚖️', 'Junta de Gobierno', 'La Hermandad', 'Junta de Gobierno', 'Mandato de 4 años, hasta el 30 de junio de 2027.',
  '[{"subtitulo":"","texto":"El viernes 30 de junio de 2023, los hermanos eligieron en las urnas la candidatura presentada en cabildo de elecciones, resultando elegido Hermano Mayor Don Francisco Javier Peinado Bueno. El 3 de julio de 2023, el delegado episcopal de Hermandades y Cofradías de Cádiz dispuso el nombramiento de la nueva Junta de Gobierno."}]'::jsonb,
  '["https://hermandadamargura.es/images/1024/16997712/0694d45a-540d-47ce-b14d-1160f495349d-6lNBMDaS5u60cc2w3hQHlg.JPG"]'::jsonb,
  3
) on conflict (slug) do update set
  icono = excluded.icono, nombre = excluded.nombre, antetitulo = excluded.antetitulo,
  titulo = excluded.titulo, entradilla = excluded.entradilla,
  bloques = excluded.bloques, fotos = excluded.fotos, orden = excluded.orden;

insert into public.paginas (slug, icono, nombre, antetitulo, titulo, entradilla, bloques, fotos, orden) values (
  'sede', '⛪', 'Sede Canónica', 'La Hermandad', 'Sede Canónica', 'Santuario de la Inmaculada Concepción, en la plaza central de La Línea de la Concepción.',
  '[{"subtitulo":"","texto":"Ubicado en la plaza central de La Línea de la Concepción, es un templo de estilo colonial construido en el siglo XIX. Se inauguró oficialmente el 8 de diciembre de 1879, coincidiendo con la festividad de la Virgen bajo cuya advocación se consagró."},{"subtitulo":"Arquitectura","texto":"Planta de tres naves, con la central notablemente más elevada, separadas por arcos de medio punto sobre pilastras. La fachada, de gran sencillez y belleza, se remata con una espadaña de cuatro campanas y un frontón curvo."},{"subtitulo":"Retablo e imagen titular","texto":"Destaca un retablo mayor barroco-castellano del siglo XVII, donado en 1916 por la duquesa de Parcent. La imagen titular de la Inmaculada, obra del escultor sanroqueño Luis Ortega Bru (1954), preside dicho retablo."},{"subtitulo":"Santuario y veneración popular","texto":"En 2005 obtuvo oficialmente el título de Santuario gracias a la iniciativa de nuestra Corporación. Es la sede parroquial y custodio de la patrona de la ciudad. Durante la Semana Santa, las hermandades realizan la estación de penitencia frente a sus puertas como muestra de veneración."}]'::jsonb,
  '["assets/sede-canonica.png"]'::jsonb,
  4
) on conflict (slug) do update set
  icono = excluded.icono, nombre = excluded.nombre, antetitulo = excluded.antetitulo,
  titulo = excluded.titulo, entradilla = excluded.entradilla,
  bloques = excluded.bloques, fotos = excluded.fotos, orden = excluded.orden;

insert into public.paginas (slug, icono, nombre, antetitulo, titulo, entradilla, bloques, fotos, orden) values (
  'casa', '🏠', 'Casa Hermandad', 'La Hermandad', 'Casa Hermandad', 'Calle Isabel la Católica, 34 · La Línea de la Concepción.',
  '[{"subtitulo":"","texto":"La actual sede administrativa de nuestra Corporación está situada en la calle Isabel la Católica, número 34, en pleno centro de La Línea de la Concepción."},{"subtitulo":"","texto":"Se inauguró en 2014, siendo Hermano Mayor N.H.D. Francisco Corral Rojas, aunque su construcción comenzó antes, cuando la Junta encabezada por N.H.D. Rogelio Muñiz Infante designó una comisión dirigida por N.H.D. Carlos Ruiz para llevar a cabo este gran proyecto."},{"subtitulo":"","texto":"Cuenta con 82 metros cuadrados que permiten almacenar los enseres de forma adecuada para su conservación, además de realizar labores administrativas y convivencias. Es, por tanto, una casa más para todos los hermanos."},{"subtitulo":"","texto":"A primeros de 2025 se restauraron el techo, el interior y la fachada. Actualmente la Junta continúa recaudando fondos para finalizar las mejoras del proyecto iniciado por juntas anteriores."}]'::jsonb,
  '["https://hermandadamargura.es/images/1024/16996656/485657012_29708296915450912_3892864417941526635_n-1024x1024-TX87wPvbKKgKy5CoUn6NfQ.jpg"]'::jsonb,
  5
) on conflict (slug) do update set
  icono = excluded.icono, nombre = excluded.nombre, antetitulo = excluded.antetitulo,
  titulo = excluded.titulo, entradilla = excluded.entradilla,
  bloques = excluded.bloques, fotos = excluded.fotos, orden = excluded.orden;

insert into public.paginas (slug, icono, nombre, antetitulo, titulo, entradilla, bloques, fotos, orden) values (
  'heraldica', '🛡️', 'Heráldica', 'La Hermandad', 'Heráldica', 'Escudo oval al modo eclesiástico. De gules, una Custodia Sacramentada de oro.',
  '[{"subtitulo":"","texto":"Escudo oval al modo eclesiástico. De gules, una Custodia Sacramentada de oro, acolada en su centro por un bezante de plata con la Nómina Sacra de Jesús Hombre Salvador de sable, radiado de oro."},{"subtitulo":"","texto":"Adiestrada y siniestrada por tres escudos ovales fileteados de oro: el diestro con las Armas de la Casa Real de España; el siniestro con una A y una M acoladas, símbolo de la Santísima Virgen María; y en punta, un lienzo de muralla entre dos torres, timbrado por Corona Real Borbónica, que representa a la Ciudad de La Línea de la Concepción. Todo rodeado por lambrequines de oro y timbrado por una Corona Real cerrada."},{"subtitulo":"Sacramental","texto":"La Hermandad se fundó para rendir culto al Santísimo Sacramento, siendo la encargada de organizar el Solemne Tríduo Eucarístico y la Procesión del Corpus Christi en el Santuario de la Inmaculada Concepción."},{"subtitulo":"Real","texto":"Concedido en 1955 por el Jefe de la Casa Real de España, SAR D. Juan de Borbón, Hermano Mayor Honorario de la Corporación, quien concedió también las Armas de la Corona para el escudo."},{"subtitulo":"Venerable","texto":"De carácter devocional."}]'::jsonb,
  '["https://hermandadamargura.es/images/434/16915422/Logo_Amargura-removebg-preview-NoRkZKT-R2FuU_xwnzr-7g.png"]'::jsonb,
  6
) on conflict (slug) do update set
  icono = excluded.icono, nombre = excluded.nombre, antetitulo = excluded.antetitulo,
  titulo = excluded.titulo, entradilla = excluded.entradilla,
  bloques = excluded.bloques, fotos = excluded.fotos, orden = excluded.orden;

insert into public.paginas (slug, icono, nombre, antetitulo, titulo, entradilla, bloques, fotos, orden) values (
  'caridad', '❤️', 'Caridad', 'La Hermandad', 'Caridad', 'Una de las principales acciones que realiza nuestra Corporación durante todo el año es conseguir recursos para destinarlos a los más necesitados.',
  '[{"subtitulo":"","texto":"Colaboramos de forma permanente con Cáritas Parroquial recogiendo alimentos de primera necesidad para las familias de nuestra feligresía. Durante la DANA recogimos más de 6 palés de recursos para los afectados por esta terrible crisis climática."},{"subtitulo":"Cómo colaborar","texto":"Puedes aportar alimentos en la Casa Hermandad o hacer un donativo puntual destinado íntegramente a la bolsa de caridad."}]'::jsonb,
  '["https://hermandadamargura.es/images/1024/17022336/valencia1__01-DkEcWDII3wHfjapcHgp2Zw.JPG"]'::jsonb,
  7
) on conflict (slug) do update set
  icono = excluded.icono, nombre = excluded.nombre, antetitulo = excluded.antetitulo,
  titulo = excluded.titulo, entradilla = excluded.entradilla,
  bloques = excluded.bloques, fotos = excluded.fotos, orden = excluded.orden;

insert into public.paginas (slug, icono, nombre, antetitulo, titulo, entradilla, bloques, fotos, orden) values (
  'grupo-joven', '🌿', 'Grupo Joven', 'La Hermandad', 'Grupo Joven', 'Creado oficialmente el 8 de enero de 2010.',
  '[{"subtitulo":"","texto":"El Grupo Joven de nuestra Corporación fue creado oficialmente el 8 de enero de 2010, formalizándose el 13 de febrero con su presentación durante los cultos de la Hermandad, en la que sus miembros juraron las Reglas y el Reglamento."},{"subtitulo":"","texto":"Los jóvenes son el futuro de la Hermandad: colaboran en los cultos, en la organización de actos y en la vida diaria de la corporación, transmitiendo la devoción a las nuevas generaciones."}]'::jsonb,
  '["https://hermandadamargura.es/images/1024/16997304/juntajovenbie_-bIOsYt1ybwmzYgcmSk94Dw.JPG"]'::jsonb,
  8
) on conflict (slug) do update set
  icono = excluded.icono, nombre = excluded.nombre, antetitulo = excluded.antetitulo,
  titulo = excluded.titulo, entradilla = excluded.entradilla,
  bloques = excluded.bloques, fotos = excluded.fotos, orden = excluded.orden;


-- ============================================================================
--  2. NOTICIAS (Actualidad)
-- ============================================================================

delete from public.noticias;

insert into public.noticias (titulo, fecha, extracto, texto, imagen_url, estado) values (
  'Procesión del Santísimo Sacramento', '21 Junio 2025', 'El domingo 22 de junio, festividad del Corpus, la Solemne Procesión de Jesús Sacramentado recorre nuestra feligresía.', 'La Hermandad, de carácter sacramental desde su fundación, organiza cada año la Solemne Procesión del Santísimo Sacramento por las calles de la feligresía del Santuario de la Inmaculada Concepción.

El cortejo saldrá a las 20:00 horas, acompañado por los hermanos con cirio y la Junta de Gobierno presidiendo bajo pertiguero.', 'https://hermandadamargura.es/images/1024/17115483/WhatsApp-Image-2025-06-15-at-20.32.59-5i_7AiY1W2cA7rp5OVoxcQ.jpeg', 'Publicada');

insert into public.noticias (titulo, fecha, extracto, texto, imagen_url, estado) values (
  'I Torrijada Solidaria', '14 Marzo 2026', 'Del 19 al 22 de marzo, una propuesta irresistible para los amantes de la tradición y la solidaridad.', 'La Hermandad celebra su I Torrijada Solidaria en la Casa Hermandad, con torrijas elaboradas artesanalmente por hermanos y colaboradores.

La recaudación íntegra se destinará a la bolsa de caridad, que colabora de forma permanente con Cáritas Parroquial.', 'https://hermandadamargura.es/images/971/24031242/Capturadepantalla2026-03-14alas2.08.53-hkPjXdtl5ecnY1HkO24LcQ.png', 'Publicada');

insert into public.noticias (titulo, fecha, extracto, texto, imagen_url, estado) values (
  'Convocatoria de Cabildo General', '02 Febrero 2026', 'Se convoca a todos los hermanos al Cabildo General Ordinario de cuentas.', 'Por orden del Hermano Mayor, y de conformidad con nuestras Reglas, se convoca a todos los hermanos mayores de 18 años con al menos un año de antigüedad al Cabildo General Ordinario de cuentas.

Tendrá lugar en la Casa Hermandad en primera convocatoria a las 19:00 horas y en segunda a las 19:30 horas.', 'https://hermandadamargura.es/images/1024/16997712/0694d45a-540d-47ce-b14d-1160f495349d-6lNBMDaS5u60cc2w3hQHlg.JPG', 'Publicada');

insert into public.noticias (titulo, fecha, extracto, texto, imagen_url, estado) values (
  'Campaña de Caridad', '10 Enero 2026', 'Recogida de alimentos para las familias de la parroquia durante todo el mes.', 'Durante todo el mes de enero, la Hermandad mantiene abierto el punto de recogida de alimentos en la Casa Hermandad, en horario de secretaría.

Se necesitan especialmente aceite, conservas, legumbres, leche y alimentos infantiles no perecederos.', 'https://hermandadamargura.es/images/1024/17022336/valencia1__01-DkEcWDII3wHfjapcHgp2Zw.JPG', 'Publicada');

insert into public.noticias (titulo, fecha, extracto, texto, imagen_url, estado) values (
  'Ayuda a los afectados por la DANA', '20 Nov 2025', 'Recogimos más de 6 palés de recursos para los afectados por esta terrible crisis climática.', 'Ante la emergencia provocada por la DANA, la Hermandad activó una recogida extraordinaria de material de primera necesidad que superó todas las previsiones.

Gracias a la generosidad de hermanos, vecinos y comercios de La Línea se reunieron más de seis palés.', 'https://hermandadamargura.es/images/1024/17022336/valencia1__01-DkEcWDII3wHfjapcHgp2Zw.JPG', 'Publicada');

insert into public.noticias (titulo, fecha, extracto, texto, imagen_url, estado) values (
  '70 aniversario fundacional', '15 Feb 2025', 'La Corporación cumplió 70 años desde su fundación el 15 de febrero de 1955.', 'El 15 de febrero de 2025 nuestra Corporación cumplió setenta años desde su fundación, en 1955, en el Santuario de la Inmaculada Concepción de La Línea de la Concepción.

La efeméride se conmemoró con una solemne función de acción de gracias y una convivencia de hermanos.', 'https://hermandadamargura.es/images/1024/16917111/IMG-20160128-WA0001_Original-M4UCvUmwP9swcc0izOWZxg.JPG', 'Publicada');


-- ============================================================================
--  3. FOTOS ROTATORIAS DE LA CABECERA
-- ============================================================================

delete from public.fotos_portada;

insert into public.fotos_portada (url, orden) values ('https://hermandadamargura.es/images/1200x630/20811590/Imagen031-JE_blfZGG-PeVbef1zBsMA.jpg', 1);
insert into public.fotos_portada (url, orden) values ('https://hermandadamargura.es/images/1024/16917111/IMG-20160128-WA0001_Original-M4UCvUmwP9swcc0izOWZxg.JPG', 2);
insert into public.fotos_portada (url, orden) values ('https://hermandadamargura.es/images/872/16995418/VirgenAmargura-Ukbvn4YNOhOBJBgmdlscTg.jpg', 3);
insert into public.fotos_portada (url, orden) values ('https://hermandadamargura.es/images/1024/17115483/WhatsApp-Image-2025-06-15-at-20.32.59-5i_7AiY1W2cA7rp5OVoxcQ.jpeg', 4);
insert into public.fotos_portada (url, orden) values ('https://hermandadamargura.es/images/1024/16997304/juntajovenbie_-bIOsYt1ybwmzYgcmSk94Dw.JPG', 5);


-- ============================================================================
--  4. BOLETINES
--     Sin PDF todavía: se suben desde el panel (Contenido web → Boletines)
-- ============================================================================

delete from public.boletines;

insert into public.boletines (titulo, meta, orden) values
  ('Boletín 2025', 'Cuaresma · 24 páginas', 1),
  ('Boletín 2024', 'Cuaresma · 20 páginas', 2),
  ('Boletín 2023', 'Cuaresma · 20 páginas', 3),
  ('Especial 70 aniversario', '1955–2025', 4);


-- ============================================================================
--  5. AJUSTES
-- ============================================================================

insert into public.ajustes (clave, valor) values
  ('bizum_numero', '623 200 617'),
  ('email_contacto', 'secretaria@hermandadamargura.es'),
  ('telefono', '956 000 000'),
  ('direccion', 'Calle Isabel la Católica, 34 · La Línea de la Concepción (Cádiz)')
on conflict (clave) do update set valor = excluded.valor;


-- ============================================================================
--  COMPROBACIÓN
-- ============================================================================

select 'paginas'       as tabla, count(*) from public.paginas
union all select 'noticias',      count(*) from public.noticias
union all select 'cultos',        count(*) from public.cultos
union all select 'boletines',     count(*) from public.boletines
union all select 'fotos_portada', count(*) from public.fotos_portada
union all select 'hermanos',      count(*) from public.hermanos
union all select 'cuotas',        count(*) from public.cuotas;

-- Debe salir: paginas 8 · noticias 6 · cultos 4 · boletines 4 ·
--             fotos_portada 5 · hermanos 7 · cuotas 10
