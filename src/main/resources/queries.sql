-- 1. Devuelve un listado de todas las reservas realizadas durante el año 2025, cuya sala tenga un precio_hora superior a 25€.

SELECT
    r.reserva_id,
    r.fecha,
    r.hora_inicio,
    r.hora_fin,
    r.estado,
    r.horas,
    s.nombre AS nombre_sala,
    s.precio_hora
FROM reserva r
         JOIN sala s ON r.sala_id = s.sala_id
WHERE r.fecha BETWEEN '2025-01-01' AND '2025-12-31'
  AND s.precio_hora > 25
ORDER BY r.fecha;

-- 2. Devuelve un listado de todos los miembros que NO han realizado ninguna reserva.
-- esta opción es mejor porque no depende de como hagas el join y tengas duplicados y además es muy explicita semanticamente igual son validas ambas

SELECT *
FROM miembro m
WHERE NOT EXISTS (
    SELECT 1
    FROM reserva r
    WHERE r.miembro_id = m.miembro_id
);

SELECT m.*
FROM miembro m
LEFT JOIN reserva r
ON m.miembro_id = r.miembro_id
WHERE r.reserva_id IS NULL;

-- 3. Devuelve una lista de los id's, nombres y emails de los miembros que no tienen el teléfono registrado.
-- El listado tiene que estar ordenado inverso alfabéticamente por nombre (z..a).
SELECT miembro_id, nombre, email
FROM miembro
WHERE telefono IS NULL
   OR TRIM(telefono) = ''
ORDER BY nombre DESC;
-- TRIM elimina espacios al inicio y al final.

-- 4. Devuelve un listado con los id's y emails de los miembros que se hayan registrado con una cuenta de yahoo.es
-- en el año 2024.

SELECT miembro_id, email
FROM miembro
WHERE email LIKE '%@yahoo.es'
  AND fecha_alta BETWEEN '2024-01-01' AND '2024-12-31';
-- otra opción con las fechas es utilizar la función YEAR junto al operador de igual y la fecha a comparar

SELECT miembro_id, email
FROM miembro
WHERE email LIKE '%@yahoo.es'
   AND YEAR(fecha_alta) = 2024;

-- 5. Devuelve un listado de los miembros cuyo primer apellido es Martín. El listado tiene que estar ordenado

SELECT * FROM miembro
-- Busca cualquier cosa que no sea espacio, luego un espacio, y luego Martín
WHERE nombre LIKE '% Martín'
  AND nombre NOT LIKE '% % %' -- Esto asegura que no haya una tercera palabra
ORDER BY fecha_alta DESC, nombre ASC;

-- por fecha de alta en el coworking de más reciente a menos reciente y nombre y apellidos en orden alfabético.

-- 6. Devuelve el gasto total (estimado) que ha realizado la miembro Ana Beltrán en reservas del coworking.

SELECT SUM(s.precio_hora * r.horas *
           (1 - COALESCE(r.descuento_pct, 0) / 100)) AS gasto_total
FROM reserva r
         JOIN miembro m ON r.miembro_id = m.miembro_id
         JOIN sala s ON r.sala_id = s.sala_id
WHERE m.nombre = 'Ana Beltrán';

-- 7. Devuelve el listado de las 3 salas de menor precio_hora.

SELECT *
FROM sala
ORDER BY precio_hora ASC
LIMIT 3;

-- 8. Devuelve la reserva a la que se le ha aplicado la mayor cuantía de descuento sobre el precio sin descuento
-- (precio_hora × horas).

SELECT r.*,
       s.precio_hora * r.horas * COALESCE(r.descuento_pct, 0) / 100 AS descuento_efectivo
FROM reserva r
         JOIN sala s ON r.sala_id = s.sala_id
ORDER BY descuento_efectivo DESC
LIMIT 1;

-- 9. Devuelve los miembros que hayan tenido alguna reserva con estado 'ASISTIDA' y exactamente 10 asistentes.

SELECT DISTINCT m.*
FROM miembro m
         JOIN reserva r ON m.miembro_id = r.miembro_id
WHERE r.estado = 'ASISTIDA'
  AND r.asistentes = 10;
-- 10. Devuelve el valor mínimo de horas reservadas (campo calculado 'horas') en una reserva.
SELECT MIN(horas) AS horas_minimas
FROM reserva;

-- 11. Devuelve un listado de las salas que empiecen por 'Sala' y terminen por 'o',
-- y también las salas que terminen por 'x'.

SELECT *
FROM sala
WHERE (nombre LIKE 'Sala%o')
   OR (nombre LIKE '%x');

-- 12. Devuelve un listado que muestre todas las reservas y salas en las que se ha registrado cada miembro.
-- El resultado debe mostrar todos los datos del miembro primero junto con un sublistado de sus reservas y salas.
-- El listado debe mostrar los datos de los miembros ordenados alfabéticamente por nombre.

SELECT
    m.miembro_id,
    m.nombre,
    m.email,
    m.telefono,
    m.empresa,
    m.plan,
    m.fecha_alta,
    r.reserva_id,
    r.fecha,
    r.hora_inicio,
    r.hora_fin,
    r.horas,
    r.estado,
    r.asistentes,
    r.descuento_pct,
    r.observaciones,
    s.sala_id,
    s.nombre AS sala_nombre,
    s.ubicacion,
    s.aforo,
    s.precio_hora
FROM miembro m
         LEFT JOIN reserva r ON m.miembro_id = r.miembro_id
         LEFT JOIN sala s ON r.sala_id = s.sala_id
ORDER BY m.nombre, r.fecha, r.hora_inicio;

-- 13. Devuelve el total de personas que podrían alojarse simultáneamente en el centro en base al aforo de todas las salas.

SELECT SUM(aforo) AS total_personas
FROM sala;

-- 14. Calcula el número total de miembros (diferentes) que tienen alguna reserva.

SELECT COUNT(DISTINCT miembro_id) AS total_miembros_con_reserva
FROM reserva;

-- 15. Devuelve el listado de las salas para las que se aplica un descuento porcentual (descuento_pct) superior al 10%
-- en alguna de sus reservas.

SELECT DISTINCT s.sala_id, s.nombre, s.precio_hora, s.aforo
FROM sala s
         JOIN reserva r ON s.sala_id = r.sala_id
WHERE r.descuento_pct > 10;

-- 16. Devuelve el nombre del miembro que pagó la reserva de mayor cuantía (precio_hora × horas aplicando el descuento).

SELECT m.nombre
FROM reserva r
         JOIN miembro m ON r.miembro_id = m.miembro_id
         JOIN sala s ON r.sala_id = s.sala_id
ORDER BY (s.precio_hora * r.horas * (1 - IFNULL(r.descuento_pct, 0)/100)) DESC
LIMIT 1;

-- 17. Devuelve los nombres de los miembros que hayan coincidido en alguna reserva con la miembro Ana Beltrán
-- (misma sala y fecha con solape horario).

SELECT DISTINCT m2.nombre
FROM reserva r1
         JOIN miembro m1 ON r1.miembro_id = m1.miembro_id
         JOIN reserva r2 ON r1.sala_id = r2.sala_id
    AND r1.fecha = r2.fecha
    AND r1.hora_inicio < r2.hora_fin
    AND r1.hora_fin > r2.hora_inicio
         JOIN miembro m2 ON r2.miembro_id = m2.miembro_id
WHERE m1.nombre = 'Ana Beltrán'
  AND m2.nombre <> 'Ana Beltrán';

-- 18. Devuelve el total de lo ingresado por el coworking en reservas para el mes de enero de 2025.

SELECT SUM(r.horas * s.precio_hora * (1 - COALESCE(r.descuento_pct, 0)/100)) AS total_ingresos
FROM reserva r
         JOIN sala s ON r.sala_id = s.sala_id
WHERE r.fecha >= '2025-01-01'
  AND r.fecha < '2025-02-01';

-- 19. Devuelve el conteo de cuántos miembros tienen la observación 'Requiere equipamiento especial' en alguna de sus reservas.

SELECT COUNT(DISTINCT r.miembro_id) AS total_miembros
FROM reserva r
WHERE r.observaciones = 'Requiere equipamiento especial';

-- 20. Devuelve cuánto se ingresaría por la sala 'Auditorio Sol' si estuviera reservada durante todo su horario de apertura
-- en un día completo (sin descuentos).

SELECT (TIME_TO_SEC(cierre) - TIME_TO_SEC(apertura)) / 3600 * precio_hora AS ingreso_total
FROM sala
WHERE nombre = 'Auditorio Sol';


-- Consultas y streams adicionales sobre miembros

-- Listado de todos los miembros con: Nombre, email, plan, empresa y fecha de alta.

SELECT nombre, email, plan, empresa, fecha_alta
FROM miembro;

-- Miembros que no tienen teléfono registrado.

SELECT *
FROM miembro
WHERE telefono IS NULL
   OR TRIM(telefono) = '';

-- Miembros de cada plan (BASIC, PRO, TEAM), mostrando cuántos hay de cada tipo.

SELECT plan, COUNT(*) AS total_miembros
FROM miembro
GROUP BY plan;

-- Miembros dados de alta a partir de una determinada fecha (por ejemplo, desde junio de 2024).

SELECT nombre, fecha_alta
FROM miembro
WHERE fecha_alta >= '2024-06-01';

-- Listado general de salas con nombre, aforo y precio/hora.

SELECT nombre, aforo, precio_hora
FROM sala;

-- Salas con aforo mayor o igual que X (por ejemplo, 15 personas).

SELECT aforo, precio_hora
FROM sala
WHERE aforo >= 15;

-- Salas ordenadas por precio_hora de mayor a menor.

SELECT nombre, precio_hora
FROM sala
ORDER BY precio_hora DESC;

-- Listar las salas que disponen de pantalla = true.

SELECT nombre, recursos
FROM sala
WHERE JSON_EXTRACT(recursos, '$.pantalla') = true;

SELECT
    nombre,
    recursos->>'$.pantalla' AS pantalla
FROM sala
WHERE recursos->>'$.pantalla' = 'true';

-- Listar las salas que permiten videocall

SELECT nombre,
       JSON_EXTRACT(recursos, '$.videocall') AS videocall
FROM sala
WHERE JSON_EXTRACT(recursos, '$.videocall') = true;

-- Mostrar para cada sala el valor de un recurso concreto
-- (por ejemplo, sonido o número de microfonos si existe).

SELECT
    nombre,
    recursos->>'$.microfonos' AS microfonos
FROM sala
WHERE JSON_EXTRACT(recursos, '$.microfonos') IS NOT NULL;

-- Listado de reservas con: Nombre del miembro. Nombre de la sala. Fecha, hora de inicio, hora fin, horas totales y estado.

SELECT
    m.nombre AS miembro,
    s.nombre AS sala,
    r.fecha,
    r.hora_inicio,
    r.hora_fin,
    r.horas,
    r.estado
FROM reserva r
         JOIN miembro m ON r.miembro_id = m.miembro_id
         JOIN sala s ON r.sala_id = s.sala_id;

-- Reservas de un miembro concreto (por ejemplo, “Jorge Castillo”) he cambiado el ejemplo por uno que si tengo en bd

SELECT
    m.nombre,
    s.nombre,
    r.fecha,
    r.hora_inicio,
    r.hora_fin
FROM reserva r
         JOIN miembro m ON r.miembro_id = m.miembro_id
         JOIN sala s ON s.sala_id = r.sala_id
WHERE m.nombre = 'Jorge Castillo';

-- Reservas de un determinado mes y año (por ejemplo, octubre de 2024).

SELECT
    m.nombre AS miembro,
    s.nombre AS sala,
    r.fecha,
    r.hora_inicio,
    r.hora_fin,
    r.horas,
    r.estado
FROM reserva r
         JOIN miembro m ON r.miembro_id = m.miembro_id
         JOIN sala s ON r.sala_id = s.sala_id
WHERE YEAR(r.fecha) = 2024
  AND MONTH(r.fecha) = 10;

-- Reservas con estado PENDIENTE, CONFIRMADA, CANCELADA o ASISTIDA (según se indique).

SELECT r.*, m.nombre AS miembro, s.nombre AS sala
FROM reserva r
         JOIN miembro m ON r.miembro_id = m.miembro_id
         JOIN sala s ON r.sala_id = s.sala_id
WHERE r.estado = 'CONFIRMADA';

-- Reservas en las que se han aplicado descuentos (descuento_pct no nulo).

SELECT r.*, m.nombre AS miembro, s.nombre AS sala
FROM reserva r
         JOIN miembro m ON r.miembro_id = m.miembro_id
         JOIN sala s ON r.sala_id = s.sala_id
WHERE r.descuento_pct IS NOT NULL
  AND r.descuento_pct > 0;

-- Ingresos estimados por sala y mes:


-- Calcular el importe teórico de cada reserva:

--  importe = horas * precio_hora * (1 - descuento_pct/100)
-- (recuerda considerar descuento_pct nulo como 0).


-- Mostrar, para cada sala y mes, el total estimado.


SELECT
    s.nombre AS sala,
    YEAR(r.fecha) AS anio,
    MONTHNAME(r.fecha) AS mes,
    -- Formula: SUM(horas * precio * (1 - descuento/100))
    -- Usamos COALESCE para que los descuentos NULL cuenten como 0
    ROUND(SUM(
                  r.horas * s.precio_hora * (1 - COALESCE(r.descuento_pct, 0) / 100)
          ), 2) AS total_estimado
FROM
    reserva r
        JOIN
    sala s ON r.sala_id = s.sala_id
GROUP BY
    s.nombre,
    anio,
    MONTH(r.fecha), -- Agrupamos por el número del mes para mantener el orden cronológico
    mes
ORDER BY
    anio DESC,
    MONTH(r.fecha) ASC,
    s.nombre ASC;

-- Listar, para cada sala, cuántas reservas se han realizado en un periodo (por ejemplo, último trimestre).

SELECT
    s.nombre AS sala,
    COUNT(r.reserva_id) AS total_reservas
FROM
    sala s
        LEFT JOIN
    reserva r ON s.sala_id = r.sala_id
WHERE
    r.fecha BETWEEN '2024-10-01' AND '2024-12-31'
GROUP BY
    s.sala_id, s.nombre
ORDER BY
    total_reservas DESC;

-- Identificar la sala más reservada.

SELECT
    s.nombre AS sala,
    COUNT(r.reserva_id) AS total_reservas
FROM
    sala s
        JOIN
    reserva r ON s.sala_id = r.sala_id
GROUP BY
    s.sala_id, s.nombre
ORDER BY
    total_reservas DESC
LIMIT 1;

-- Número de reservas realizadas por cada miembro.

SELECT
    m.nombre AS miembro,
    COUNT(r.reserva_id) AS total_reservas
FROM
    miembro m
        LEFT JOIN
    reserva r ON m.miembro_id = r.miembro_id
GROUP BY
    m.miembro_id, m.nombre, m.email
ORDER BY
    total_reservas DESC;

-- Comparar el número de asistentes con el aforo de la sala en cada reserva:


-- Detectar reservas con asistentes cercanos al aforo máximo.


-- Detectar reservas infrautilizadas (por ejemplo, asistentes <= aforo/3).

SELECT
    r.reserva_id,
    s.nombre AS sala,
    s.aforo,
    r.asistentes,
    r.fecha,
    CASE
        WHEN r.asistentes >= (s.aforo * 0.9) THEN 'CRÍTICA (Casi llena)'
        WHEN r.asistentes <= (s.aforo / 3) THEN 'INFRAUTILIZADA'
        ELSE 'OPTIMA'
        END AS estado_eficiencia
FROM
    reserva r
        JOIN
    sala s ON r.sala_id = s.sala_id
WHERE
    r.asistentes IS NOT NULL
  AND r.estado != 'CANCELADA'
ORDER BY
    estado_eficiencia DESC, s.aforo DESC;

