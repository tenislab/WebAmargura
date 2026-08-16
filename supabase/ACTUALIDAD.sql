-- ============================================================================
--  ACTUALIDAD · Hermandad de la Amargura
--  Vuelca las 6 noticias completas (con su texto y su fotografía) en la
--  tabla `noticias`, para que el panel de Secretaría no aparezca vacío.
--
--  CÓMO USARLO:  Supabase → SQL Editor → New query → pega esto → RUN
--
--  Puedes ejecutarlo las veces que quieras: primero limpia y vuelve a
--  dejar las 6 noticias tal cual están en la web.
-- ============================================================================

delete from public.noticias;

insert into public.noticias (titulo, fecha, texto, imagen_url, estado) values

('Procesión del Santísimo Sacramento',
 '21 Junio 2025',
 'La Hermandad, de carácter sacramental desde su fundación, organiza cada año la Solemne Procesión del Santísimo Sacramento por las calles de la feligresía del Santuario de la Inmaculada Concepción.

El cortejo saldrá a las 20:00 horas, acompañado por los hermanos con cirio y la Junta de Gobierno presidiendo bajo pertiguero. Se ruega a los hermanos la máxima puntualidad y el debido decoro en el acompañamiento.

Los vecinos que deseen adornar sus balcones con colgaduras a lo largo del itinerario pueden solicitarlas en la Casa Hermandad durante la semana previa.',
 'https://hermandadamargura.es/images/1024/17115483/WhatsApp-Image-2025-06-15-at-20.32.59-5i_7AiY1W2cA7rp5OVoxcQ.jpeg',
 'Publicada'),

('I Torrijada Solidaria',
 '14 Marzo 2026',
 'La Hermandad celebra su I Torrijada Solidaria en la Casa Hermandad, con torrijas elaboradas artesanalmente por hermanos y colaboradores de la corporación.

La recaudación íntegra se destinará a la bolsa de caridad, que colabora de forma permanente con Cáritas Parroquial en el reparto de alimentos de primera necesidad.

Habrá servicio de barra y venta para llevar. Animamos a todos los hermanos y a sus familias a participar y a difundir la iniciativa.',
 'https://hermandadamargura.es/images/971/24031242/Capturadepantalla2026-03-14alas2.08.53-hkPjXdtl5ecnY1HkO24LcQ.png',
 'Publicada'),

('Convocatoria de Cabildo General',
 '02 Febrero 2026',
 'Por orden del Hermano Mayor, y de conformidad con nuestras Reglas, se convoca a todos los hermanos mayores de 18 años con al menos un año de antigüedad al Cabildo General Ordinario de cuentas.

Tendrá lugar en la Casa Hermandad en primera convocatoria a las 19:00 horas y en segunda a las 19:30 horas, con el siguiente orden del día: lectura del acta anterior, memoria de la Junta de Gobierno, estado de cuentas del ejercicio y ruegos y preguntas.

Los hermanos podrán consultar el estado de cuentas en Secretaría durante los cinco días previos al cabildo.',
 'https://hermandadamargura.es/images/1024/16997712/0694d45a-540d-47ce-b14d-1160f495349d-6lNBMDaS5u60cc2w3hQHlg.JPG',
 'Publicada'),

('Campaña de Caridad',
 '10 Enero 2026',
 'Durante todo el mes de enero, la Hermandad mantiene abierto el punto de recogida de alimentos en la Casa Hermandad, en horario de secretaría.

Se necesitan especialmente aceite, conservas, legumbres, leche y alimentos infantiles no perecederos. Todo lo recogido se entrega directamente a Cáritas Parroquial para su reparto.

Quien lo prefiera puede realizar una aportación económica destinada íntegramente a la bolsa de caridad.',
 'https://hermandadamargura.es/images/1024/17022336/valencia1__01-DkEcWDII3wHfjapcHgp2Zw.JPG',
 'Publicada'),

('Ayuda a los afectados por la DANA',
 '20 Nov 2025',
 'Ante la emergencia provocada por la DANA, la Hermandad activó una recogida extraordinaria de material de primera necesidad que superó todas las previsiones.

Gracias a la generosidad de hermanos, vecinos y comercios de La Línea se reunieron más de seis palés con agua, alimentos, productos de limpieza e higiene, material que fue trasladado a las zonas afectadas.

Desde la Junta de Gobierno queremos agradecer públicamente la implicación de todos los que hicieron posible esta respuesta.',
 'https://hermandadamargura.es/images/1024/17022336/valencia1__01-DkEcWDII3wHfjapcHgp2Zw.JPG',
 'Publicada'),

('70 aniversario fundacional',
 '15 Feb 2025',
 'El 15 de febrero de 2025 nuestra Corporación cumplió setenta años desde su fundación, en 1955, en el Santuario de la Inmaculada Concepción de La Línea de la Concepción.

La efeméride se conmemoró con una solemne función de acción de gracias, la presentación del boletín especial del aniversario y una convivencia de hermanos en la Casa Hermandad.

Setenta años de fe, tradición y caridad que la Hermandad quiere seguir transmitiendo a las nuevas generaciones.',
 'https://hermandadamargura.es/images/1024/16917111/IMG-20160128-WA0001_Original-M4UCvUmwP9swcc0izOWZxg.JPG',
 'Publicada');


-- ============================================================================
--  COMPROBACIÓN — debe devolver 6
-- ============================================================================

select count(*) as noticias_cargadas from public.noticias;

select titulo, fecha, estado from public.noticias order by id;
