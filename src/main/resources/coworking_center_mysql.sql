-- MySQL 8.0+ schema: Coworking Center (sin vistas, ~20 filas por tabla)
-- Estructura: miembro / sala / reserva (M:N con atributos en la tabla de intersección)
-- Clave subrogada en la intersección, checks útiles, índices y JSON en 'sala.recursos'.

SET NAMES utf8mb4;
SET time_zone = '+00:00';
SET sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO,ONLY_FULL_GROUP_BY';

-- Crear base de datos
CREATE DATABASE IF NOT EXISTS coworking_center
    CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE coworking_center;

-- Limpieza previa
DROP TABLE IF EXISTS reserva;
DROP TABLE IF EXISTS sala;
DROP TABLE IF EXISTS miembro;

-- ============================
-- 1) Maestro de miembros (20 filas)
-- ============================
CREATE TABLE miembro (
                         miembro_id   BIGINT NOT NULL AUTO_INCREMENT,
                         nombre       VARCHAR(150) NOT NULL,
                         email        VARCHAR(190) NOT NULL,
                         telefono     VARCHAR(20)  NULL,
                         empresa      VARCHAR(160) NULL,
                         plan         VARCHAR(10)  NOT NULL DEFAULT 'BASIC', -- BASIC | PRO | TEAM
                         fecha_alta   DATE         NOT NULL,
                         CONSTRAINT pk_miembro PRIMARY KEY (miembro_id),
                         CONSTRAINT uq_miembro_email UNIQUE (email),
                         CONSTRAINT ck_miembro_nombre CHECK (CHAR_LENGTH(nombre) >= 3),
                         CONSTRAINT ck_miembro_plan CHECK (plan IN ('BASIC','PRO','TEAM'))
) ENGINE=InnoDB;

INSERT INTO miembro (nombre, email, telefono, empresa, plan, fecha_alta) VALUES
                                                                             ('Ana Beltrán',        'ana.beltran@ejemplo.com',       '600100200', 'DevByte S.L.',     'PRO',  '2024-01-12'),
                                                                             ('Jorge Castillo',     'jorge.castillo@ejemplo.com',    NULL,        NULL,               'BASIC','2024-02-03'),
                                                                             ('Marta Cordero',      'marta.cordero@ejemplo.com',     '600300400', 'Marketly S.A.',    'TEAM', '2024-03-21'),
                                                                             ('Daniel Romero',      'daniel.romero@ejemplo.com',     '600500600', NULL,               'BASIC','2024-04-02'),
                                                                             ('Noa Sánchez',        'noa.sanchez@ejemplo.com',       NULL,        'DataNest S.L.',    'PRO',  '2024-04-20'),
                                                                             ('Lucas Herrera',      'lucas.herrera@ejemplo.com',     '600700800', 'CodeCloud S.L.',   'PRO',  '2024-04-25'),
                                                                             ('Paula Martín',       'paula.martin@ejemplo.com',      NULL,        'Creatia Studio',   'BASIC','2024-05-02'),
                                                                             ('Iván Navarro',       'ivan.navarro@ejemplo.com',      '600900000', NULL,               'PRO',  '2024-05-10'),
                                                                             ('Elena Ruiz',         'elena.ruiz@ejemplo.com',        '601111222', 'HealthAI S.L.',    'TEAM', '2024-05-18'),
                                                                             ('David Torres',       'david.torres@ejemplo.com',      '601333444', NULL,               'BASIC','2024-06-01'),
                                                                             ('Claudia López',      'claudia.lopez@ejemplo.com',     '601555666', 'Loop Media',       'PRO',  '2024-06-07'),
                                                                             ('Rubén García',       'ruben.garcia@ejemplo.com',      NULL,        'OpenEdge',         'TEAM', '2024-06-15'),
                                                                             ('Silvia Moreno',      'silvia.moreno@ejemplo.com',     '601777888', NULL,               'BASIC','2024-06-20'),
                                                                             ('Álvaro Pérez',       'alvaro.perez@ejemplo.com',      '601999000', 'GreenBits',        'PRO',  '2024-07-05'),
                                                                             ('Laura Iglesias',     'laura.iglesias@ejemplo.com',    NULL,        NULL,               'BASIC','2024-07-09'),
                                                                             ('Sergio Ortega',      'sergio.ortega@ejemplo.com',     '602111222', 'Fintegra',         'PRO',  '2024-07-20'),
                                                                             ('Marina Vidal',       'marina.vidal@ejemplo.com',      '602333444', 'UXWorks',          'TEAM', '2024-08-01'),
                                                                             ('Óscar Núñez',        'oscar.nunez@ejemplo.com',       NULL,        'NetFlow S.L.',     'BASIC','2024-08-10'),
                                                                             ('Andrea Santos',      'andrea.santos@ejemplo.com',     '602555666', NULL,               'PRO',  '2024-08-18'),
                                                                             ('Pablo Rojas',        'pablo.rojas@ejemplo.com',       '602777888', 'AstralTech',       'TEAM', '2024-08-25');

-- ============================
-- 2) Maestro de salas (20 filas)
-- ============================
CREATE TABLE sala (
                      sala_id      BIGINT NOT NULL AUTO_INCREMENT,
                      nombre       VARCHAR(120) NOT NULL,
                      ubicacion    VARCHAR(200) NOT NULL,
                      aforo        INT NOT NULL,
                      precio_hora  DECIMAL(10,2) NOT NULL,
                      apertura     TIME NOT NULL,
                      cierre       TIME NOT NULL,
                      recursos     JSON NULL, -- p.ej. {"pantalla":true,"pizarra":true,"conexiones":["HDMI","USB-C"]}
                      CONSTRAINT pk_sala PRIMARY KEY (sala_id),
                      CONSTRAINT uq_sala_nombre UNIQUE (nombre),
                      CONSTRAINT ck_sala_aforo CHECK (aforo > 0),
                      CONSTRAINT ck_sala_precio CHECK (precio_hora >= 0),
                      CONSTRAINT ck_sala_horario CHECK (cierre > apertura)
) ENGINE=InnoDB;

INSERT INTO sala (nombre, ubicacion, aforo, precio_hora, apertura, cierre, recursos) VALUES
                                                                                         ('Sala Retiro',      'Planta 1 · Ala A',  8,  18.00, '08:00:00', '21:00:00', JSON_OBJECT('pantalla', true, 'pizarra', true, 'conexiones', JSON_ARRAY('HDMI','USB-C'))),
                                                                                         ('Sala Prado',       'Planta 1 · Ala B', 14,  25.00, '08:00:00', '21:00:00', JSON_OBJECT('pantalla', true, 'pizarra', true, 'videocall', true)),
                                                                                         ('Box Cibeles',      'Planta 2 · Box 3',  3,  10.00, '08:00:00', '21:00:00', JSON_OBJECT('silencioso', true)),
                                                                                         ('Auditorio Sol',    'Planta 0 · Hall',  50,  45.00, '08:00:00', '22:00:00', JSON_OBJECT('sonido', '5.1', 'microfonos', 4)),
                                                                                         ('Sala Gran Vía',    'Planta 2 · Ala C', 12,  22.00, '08:00:00', '21:00:00', JSON_OBJECT('pantalla', true, 'pizarra', true)),
                                                                                         ('Sala Atocha',      'Planta 3 · Ala D', 10,  20.00, '08:00:00', '21:00:00', JSON_OBJECT('pizarra', true)),
                                                                                         ('Sala Vallecas',      'Planta 3 · Ala E',  6,  16.00, '08:00:00', '21:00:00', JSON_OBJECT('pantalla', true)),
                                                                                         ('Sala Malasaña',    'Planta 2 · Ala F',  8,  17.50, '08:00:00', '21:00:00', JSON_OBJECT('pizarra', true, 'ventilacion', 'extra')),
                                                                                         ('Box Lavapiés',     'Planta 2 · Box 1',  2,  12.00, '08:00:00', '21:00:00', JSON_OBJECT('silencioso', true)),
                                                                                         ('Box Chamberí',     'Planta 2 · Box 2',  2,  12.50, '08:00:00', '21:00:00', JSON_OBJECT('silencioso', true, 'luz', 'natural')),
                                                                                         ('Sala Castellana',  'Planta 4 · Ala A', 16,  28.00, '08:00:00', '21:00:00', JSON_OBJECT('pantalla', true, 'conexiones', JSON_ARRAY('HDMI','DP'))),
                                                                                         ('Sala Salamanca',   'Planta 4 · Ala B', 18,  30.00, '08:00:00', '21:00:00', JSON_OBJECT('pantalla', true, 'pizarra', true, 'videocall', true)),
                                                                                         ('Sala Delicias',    'Planta 1 · Ala C', 10,  19.00, '08:00:00', '21:00:00', JSON_OBJECT('pizarra', true)),
                                                                                         ('Sala Moncloa',     'Planta 1 · Ala D', 14,  23.00, '08:00:00', '21:00:00', JSON_OBJECT('pantalla', true)),
                                                                                         ('Sala Latina',      'Planta 3 · Ala F', 12,  21.00, '08:00:00', '21:00:00', JSON_OBJECT('pizarra', true)),
                                                                                         ('Sala Tetuán',      'Planta 5 · Ala A', 20,  32.00, '08:00:00', '21:00:00', JSON_OBJECT('pantalla', true, 'pizarra', true)),
                                                                                         ('Box Bilbao',       'Planta 5 · Box 4',  3,  11.00, '08:00:00', '21:00:00', JSON_OBJECT('silencioso', true)),
                                                                                         ('Sala Argüelles',   'Planta 3 · Ala G', 10,  20.50, '08:00:00', '21:00:00', JSON_OBJECT('pantalla', true, 'videocall', true)),
                                                                                         ('Sala Ópera',       'Planta 2 · Ala G', 22,  35.00, '08:00:00', '22:00:00', JSON_OBJECT('sonido', 'estereo', 'iluminacion', 'escena')),
                                                                                         ('Sala Embajadores', 'Planta 0 · Ala E', 26,  38.00, '08:00:00', '22:00:00', JSON_OBJECT('sonido', '4.0', 'microfonos', 2));

-- ============================
-- 3) Intersección: Reservas (40 filas)
-- ============================
CREATE TABLE reserva (
                         reserva_id    BIGINT NOT NULL AUTO_INCREMENT,
                         miembro_id    BIGINT NOT NULL,
                         sala_id       BIGINT NOT NULL,
                         fecha         DATE   NOT NULL,
                         hora_inicio   TIME   NOT NULL,
                         hora_fin      TIME   NOT NULL,
                         estado        VARCHAR(12) NOT NULL DEFAULT 'PENDIENTE', -- PENDIENTE | CONFIRMADA | CANCELADA | ASISTIDA
                         asistentes    INT NULL,
                         descuento_pct DECIMAL(5,2) NULL, -- 0..100
                         observaciones TEXT NULL,
                         horas DECIMAL(6,2) AS (ROUND(TIME_TO_SEC(TIMEDIFF(hora_fin, hora_inicio)) / 3600, 2)) STORED,
                         CONSTRAINT pk_reserva PRIMARY KEY (reserva_id),
                         CONSTRAINT fk_reserva_miembro FOREIGN KEY (miembro_id)
                             REFERENCES miembro(miembro_id) ON DELETE CASCADE,
                         CONSTRAINT fk_reserva_sala FOREIGN KEY (sala_id)
                             REFERENCES sala(sala_id) ON DELETE CASCADE,
                         CONSTRAINT ck_reserva_horas CHECK (hora_fin > hora_inicio),
                         CONSTRAINT ck_reserva_estado CHECK (estado IN ('PENDIENTE','CONFIRMADA','CANCELADA','ASISTIDA')),
                         CONSTRAINT ck_reserva_asistentes CHECK (asistentes IS NULL OR asistentes >= 1),
                         CONSTRAINT ck_reserva_descuento CHECK (descuento_pct IS NULL OR (descuento_pct >= 0 AND descuento_pct <= 100))
) ENGINE=InnoDB;

-- Índices de ayuda
CREATE INDEX idx_reserva_sala_fecha ON reserva (sala_id, fecha);
CREATE INDEX idx_reserva_miembro_fecha ON reserva (miembro_id, fecha);

INSERT INTO reserva (miembro_id, sala_id, fecha, hora_inicio, hora_fin, estado, asistentes, descuento_pct, observaciones) VALUES
                                                                                                                              (1,  1, '2024-09-10', '09:00:00', '12:00:00', 'ASISTIDA',   4,  0.00,  'Daily de equipo'),
                                                                                                                              (2,  3, '2024-09-11', '10:00:00', '12:30:00', 'ASISTIDA',   1,  NULL,  NULL),
                                                                                                                              (3,  2, '2024-09-15', '16:00:00', '19:00:00', 'ASISTIDA',   8,  10.00, 'Workshop marketing'),
                                                                                                                              (4,  1, '2024-10-02', '11:00:00', '13:00:00', 'CONFIRMADA', 2,  NULL,  NULL),
                                                                                                                              (5,  4, '2024-10-08', '17:00:00', '20:00:00', 'ASISTIDA',  25,  5.00,  'Demo de producto'),
                                                                                                                              (6,  2, '2024-10-12', '09:30:00', '11:30:00', 'ASISTIDA',   3,  NULL,  'Sesión ventas'),
                                                                                                                              (7,  5, '2024-10-18', '15:00:00', '17:00:00', 'CANCELADA',  2,  NULL,  'Anulación por cliente'),
                                                                                                                              (8, 11, '2024-10-20', '10:00:00', '12:00:00', 'ASISTIDA',   5,  0.00,  NULL),
                                                                                                                              (9, 12, '2024-10-22', '12:00:00', '14:00:00', 'CONFIRMADA', 6,  NULL,  'Planificación Q4'),
                                                                                                                              (10, 6,'2024-10-25', '10:00:00', '13:00:00', 'ASISTIDA',    3,  15.00, 'Formación interna'),
                                                                                                                              (11, 7,'2024-11-01', '09:00:00', '11:00:00', 'PENDIENTE',   2,  NULL,  'Revisión creativa'),
                                                                                                                              (12, 8,'2024-11-03', '16:00:00', '18:30:00', 'ASISTIDA',    4,  5.00,  'Diseño de campaña'),
                                                                                                                              (13, 9,'2024-11-05', '08:30:00', '10:00:00', 'ASISTIDA',    1,  0.00,  'Llamadas'),
                                                                                                                              (14,10,'2024-11-08', '14:00:00', '16:00:00', 'CONFIRMADA',  2,  NULL,  NULL),
                                                                                                                              (15,13,'2024-11-12', '17:00:00', '19:00:00', 'ASISTIDA',    6,  10.00, 'Retro del sprint'),
                                                                                                                              (16,14,'2024-11-15', '11:00:00', '13:30:00', 'ASISTIDA',    5,  NULL,  'Cierre MVP'),
                                                                                                                              (17,15,'2024-11-18', '09:00:00', '10:30:00', 'PENDIENTE',   2,  NULL,  'Aprobación pendiente'),
                                                                                                                              (18,16,'2024-11-21', '12:00:00', '15:00:00', 'ASISTIDA',   10,  0.00,  'Meetup comunidad'),
                                                                                                                              (19,17,'2024-11-25', '10:00:00', '12:30:00', 'CANCELADA',   2,  NULL,  'Solapado'),
                                                                                                                              (20,18,'2024-11-28', '16:00:00', '18:00:00', 'CONFIRMADA',  3,  NULL,  NULL),
                                                                                                                              (1, 19,'2024-12-02', '09:30:00', '11:30:00', 'ASISTIDA',    4,  0.00,  'Plan 2025'),
                                                                                                                              (2, 20,'2024-12-04', '15:00:00', '17:00:00', 'ASISTIDA',    6,  5.00,  'Demo partners'),
                                                                                                                              (3,  4,'2024-12-10', '10:00:00', '12:00:00', 'ASISTIDA',   12,  0.00,  'Ensayo evento'),
                                                                                                                              (4,  5,'2024-12-12', '13:00:00', '15:00:00', 'CONFIRMADA',  3,  NULL,  NULL),
                                                                                                                              (5,  6,'2024-12-15', '09:00:00', '11:00:00', 'ASISTIDA',    2,  0.00,  'One-to-one'),
                                                                                                                              (6,  7,'2024-12-18', '18:00:00', '20:00:00', 'PENDIENTE',   4,  NULL,  NULL),
                                                                                                                              (7,  8,'2024-12-20', '10:00:00', '12:30:00', 'ASISTIDA',    5,  10.00, 'Kickoff Q1'),
                                                                                                                              (8,  9,'2025-01-08', '11:00:00', '13:00:00', 'ASISTIDA',    2,  0.00,  NULL),
                                                                                                                              (9, 10,'2025-01-10', '09:00:00', '11:00:00', 'ASISTIDA',    2,  NULL,  'Plan de marketing'),
                                                                                                                              (10,11,'2025-01-14', '12:00:00', '14:00:00', 'CONFIRMADA',  3,  5.00,  NULL),
                                                                                                                              (11,12,'2025-01-17', '16:00:00', '18:00:00', 'ASISTIDA',    4,  0.00,  NULL),
                                                                                                                              (12,13,'2025-01-20', '10:30:00', '12:00:00', 'ASISTIDA',    1,  NULL,  'Reunión rápida'),
                                                                                                                              (13,14,'2025-01-23', '14:00:00', '17:00:00', 'PENDIENTE',   6,  NULL,  NULL),
                                                                                                                              (14,15,'2025-01-27', '09:00:00', '11:00:00', 'ASISTIDA',    3,  0.00,  'Plan de calidad'),
                                                                                                                              (15,16,'2025-01-30', '17:00:00', '19:30:00', 'ASISTIDA',    7,  15.00, 'Ensayo charla'),
                                                                                                                              (16,17,'2025-02-03', '08:30:00', '10:00:00', 'CONFIRMADA',  2,  NULL,  NULL),
                                                                                                                              (17,18,'2025-02-06', '11:00:00', '13:00:00', 'ASISTIDA',    5,  0.00,  'Formación'),
                                                                                                                              (18,19,'2025-02-10', '15:00:00', '17:00:00', 'ASISTIDA',    6,  5.00,  'Revisión roadmap'),
                                                                                                                              (19,20,'2025-02-14', '10:00:00', '12:30:00', 'PENDIENTE',   4,  NULL,  'Pendiente proveedor'),
                                                                                                                              (20, 1,'2025-02-18', '13:00:00', '15:00:00', 'ASISTIDA',    3,  0.00,  'Cierre mensual'),
                                                                                                                              (3,  3,'2025-02-21', '09:00:00', '11:00:00', 'ASISTIDA',    2,  NULL,  'Seguimiento'),
                                                                                                                              (5,  2,'2025-02-24', '16:00:00', '18:30:00', 'CONFIRMADA',  8,  10.00, 'Demo clientes'),
                                                                                                                              (8,  4,'2025-02-27', '10:00:00', '12:00:00', 'ASISTIDA',   15,  0.00,  'Evento pequeño'),
                                                                                                                              (10, 5,'2025-03-03', '12:00:00', '14:00:00', 'ASISTIDA',    4,  0.00,  'Revisión financiera'),
                                                                                                                              (12, 6,'2025-03-06', '09:30:00', '11:30:00', 'PENDIENTE',   3,  NULL,  NULL),
                                                                                                                              (14, 7,'2025-03-10', '15:00:00', '17:00:00', 'ASISTIDA',    2,  0.00,  'Plan SEO'),
                                                                                                                              (16, 8,'2025-03-12', '16:00:00', '18:30:00', 'ASISTIDA',    5,  5.00,  'UX review'),
                                                                                                                              (18, 9,'2025-03-15', '10:00:00', '12:00:00', 'CONFIRMADA',  2,  NULL,  NULL),
                                                                                                                              (20,10,'2025-03-18', '11:00:00', '13:00:00', 'ASISTIDA',    3,  0.00,  'Sprint planning');

-- ============================
-- Consultas de ejemplo (comentadas)
-- ============================
-- SELECT COUNT(*) AS miembros FROM miembro;
-- SELECT COUNT(*) AS salas FROM sala;
-- SELECT COUNT(*) AS reservas FROM reserva;