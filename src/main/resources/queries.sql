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

