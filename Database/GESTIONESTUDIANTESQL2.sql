-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versión del servidor:         10.4.32-MariaDB - mariadb.org binary distribution
-- SO del servidor:              Win64
-- HeidiSQL Versión:             12.8.0.6908
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Volcando estructura de base de datos para gestiondeestudiantes
CREATE DATABASE IF NOT EXISTS `gestiondeestudiantes` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;
USE `gestiondeestudiantes`;

-- Volcando estructura para tabla gestiondeestudiantes.administradores
DROP TABLE IF EXISTS `administradores`;
CREATE TABLE IF NOT EXISTS `administradores` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `correo` varchar(100) NOT NULL,
  `contraseña` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `correo` (`correo`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla gestiondeestudiantes.administradores: ~0 rows (aproximadamente)
INSERT INTO `administradores` (`id`, `nombre`, `correo`, `contraseña`) VALUES
	(1, 'admin', 'admin@gmail.com', 'scrypt:32768:8:1$uiQOVWHGd2vGFW83$45db538c5a90cd3a96ed826ebb12e604ac32f9ff177e84dac40c67b3c7a5bf02cce1e092ba3fb604d8bb924d34261dc5f8f0c14632b46b8d6ca22640ecebe777');

-- Volcando estructura para tabla gestiondeestudiantes.asignaciones
DROP TABLE IF EXISTS `asignaciones`;
CREATE TABLE IF NOT EXISTS `asignaciones` (
  `id_profesor` int(11) NOT NULL,
  `id_materia` int(11) NOT NULL,
  PRIMARY KEY (`id_profesor`,`id_materia`),
  KEY `id_materia` (`id_materia`),
  CONSTRAINT `asignaciones_ibfk_1` FOREIGN KEY (`id_profesor`) REFERENCES `profesores` (`id`) ON DELETE CASCADE,
  CONSTRAINT `asignaciones_ibfk_2` FOREIGN KEY (`id_materia`) REFERENCES `materias` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla gestiondeestudiantes.asignaciones: ~0 rows (aproximadamente)

-- Volcando estructura para tabla gestiondeestudiantes.contenidos_materia
DROP TABLE IF EXISTS `contenidos_materia`;
CREATE TABLE IF NOT EXISTS `contenidos_materia` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_profesor` int(11) NOT NULL,
  `id_materia` int(11) NOT NULL,
  `titulo` varchar(255) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `tipo` varchar(50) DEFAULT 'archivo',
  `filename` varchar(255) NOT NULL,
  `mimetype` varchar(100) DEFAULT NULL,
  `tamano` bigint(20) DEFAULT NULL,
  `ruta` varchar(500) NOT NULL,
  `fecha_subida` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_contenidos_profesor` (`id_profesor`),
  KEY `idx_contenidos_materia` (`id_materia`),
  KEY `idx_contenidos_fecha` (`fecha_subida`),
  CONSTRAINT `contenidos_materia_ibfk_1` FOREIGN KEY (`id_profesor`) REFERENCES `profesores` (`id`) ON DELETE CASCADE,
  CONSTRAINT `contenidos_materia_ibfk_2` FOREIGN KEY (`id_materia`) REFERENCES `materias` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla gestiondeestudiantes.contenidos_materia: ~0 rows (aproximadamente)
INSERT INTO `contenidos_materia` (`id`, `id_profesor`, `id_materia`, `titulo`, `descripcion`, `tipo`, `filename`, `mimetype`, `tamano`, `ruta`, `fecha_subida`) VALUES
	(1, 1, 1, 'MATERIAL DE APOYO DE CALCULO', 'LECCIONES,EJERCICIO Y TEOREMAS DE CALCULO AVANZADO', 'archivo', '1_1764898191_DESARROLLO_2.pdf', 'application/pdf', NULL, 'uploads/contenidos/1/1_1764898191_DESARROLLO_2.pdf', '2025-12-05 01:29:51');

-- Volcando estructura para función gestiondeestudiantes.dias_sin_actualizar
DROP FUNCTION IF EXISTS `dias_sin_actualizar`;
DELIMITER //
CREATE FUNCTION `dias_sin_actualizar`(p_id_profesor INT, p_id_materia INT) RETURNS int(11)
    READS SQL DATA
    DETERMINISTIC
BEGIN
    DECLARE v_dias INT;
    SELECT DATEDIFF(CURDATE(), DATE(ultima_actualizacion))
    INTO v_dias
    FROM profesor_actualizaciones_contenido
    WHERE id_profesor = p_id_profesor AND id_materia = p_id_materia;
    
    RETURN COALESCE(v_dias, 0);
END//
DELIMITER ;

-- Volcando estructura para tabla gestiondeestudiantes.entregas_tareas
DROP TABLE IF EXISTS `entregas_tareas`;
CREATE TABLE IF NOT EXISTS `entregas_tareas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_estudiante` int(11) NOT NULL,
  `id_tarea_materia` int(11) NOT NULL,
  `filename` varchar(255) NOT NULL,
  `mimetype` varchar(100) DEFAULT NULL,
  `ruta` varchar(500) NOT NULL,
  `fecha_entrega` timestamp NOT NULL DEFAULT current_timestamp(),
  `calificacion` decimal(5,2) DEFAULT NULL,
  `comentario` text DEFAULT NULL,
  `estado` enum('pendiente','entregada','calificada') DEFAULT 'entregada',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_entrega` (`id_estudiante`,`id_tarea_materia`),
  KEY `idx_entregas_estudiante` (`id_estudiante`),
  KEY `idx_entregas_tarea` (`id_tarea_materia`),
  KEY `idx_entregas_fecha` (`fecha_entrega`),
  CONSTRAINT `entregas_tareas_ibfk_1` FOREIGN KEY (`id_estudiante`) REFERENCES `estudiantes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `entregas_tareas_ibfk_2` FOREIGN KEY (`id_tarea_materia`) REFERENCES `tareas_materia` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla gestiondeestudiantes.entregas_tareas: ~1 rows (aproximadamente)
INSERT INTO `entregas_tareas` (`id`, `id_estudiante`, `id_tarea_materia`, `filename`, `mimetype`, `ruta`, `fecha_entrega`, `calificacion`, `comentario`, `estado`) VALUES
	(1, 1, 1, '1_1_1764911843_ENTREGA_FINAL.pdf', 'application/pdf', 'uploads/contenidos/entregas/1/1_1_1764911843_ENTREGA_FINAL.pdf', '2025-12-05 05:17:23', 4.00, NULL, 'entregada'),
	(4, 1, 2, '1_2_1764947286_1_1_1764911843_ENTREGA_FINAL.pdf', 'application/pdf', 'uploads/contenidos/entregas/2/1_2_1764947286_1_1_1764911843_ENTREGA_FINAL.pdf', '2025-12-05 15:08:06', NULL, NULL, 'entregada');

-- Volcando estructura para tabla gestiondeestudiantes.estudiantes
DROP TABLE IF EXISTS `estudiantes`;
CREATE TABLE IF NOT EXISTS `estudiantes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `correo` varchar(100) NOT NULL,
  `contraseña` varchar(255) NOT NULL,
  `puede_inscribirse` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `correo` (`correo`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla gestiondeestudiantes.estudiantes: ~4 rows (aproximadamente)
INSERT INTO `estudiantes` (`id`, `nombre`, `correo`, `contraseña`, `puede_inscribirse`) VALUES
	(1, 'kevin cuero', 'cuero@gmail.com', 'scrypt:32768:8:1$y0X38a2o4opf2SAS$0ff81e22b744105af48ff772f047d376097e25d4b724d8057d84af8c9893de7d5cacf6d258eb8b014ba7c9efdd44b499bc1ef93f76b377b5ada2218dbd94752f', 1),
	(2, 'zharick cuero', 'zharick@gmail.com', 'scrypt:32768:8:1$YjGraxc45Oedou2x$8c4d75ad75b856039603685d5597475b671a37c71158b2f17883256fbeddd4faa144db1c21127c353cc2183ed351d954d820bca8332d1664ab52f6f6eb4d921f', 1),
	(3, 'kevin marin', 'marin@gmail.com', 'scrypt:32768:8:1$W1EXF1CkgYE1yxxy$148300fe597250154b61551b29fc273e0c96f294dc776095f33fbbe9ec20c0c2e97563813863d53889625504820251868e27909342d07aa1d4443edf75a71012', 1),
	(4, 'juan naranjo', 'naranjo@gmail.com', 'scrypt:32768:8:1$itfycU53aCtX44JJ$998eab97c0bbd5301147c57ff44c388fc3b3782163e01b12d17f3b1b19ed0b06a31cb3ad50ede36f18ba56b45b3d12d7ed3c15ca33f75b2e8b187e41f51800aa', 1);

-- Volcando estructura para tabla gestiondeestudiantes.evaluaciones_indices
DROP TABLE IF EXISTS `evaluaciones_indices`;
CREATE TABLE IF NOT EXISTS `evaluaciones_indices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_indice` int(11) NOT NULL,
  `id_profesor` int(11) NOT NULL,
  `porcentaje_dominio` decimal(5,2) NOT NULL,
  `comentario` text DEFAULT NULL,
  `fecha_evaluacion` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_evaluaciones_indice` (`id_indice`),
  KEY `idx_evaluaciones_profesor` (`id_profesor`),
  CONSTRAINT `evaluaciones_indices_ibfk_1` FOREIGN KEY (`id_indice`) REFERENCES `indices_aprendizaje` (`id`) ON DELETE CASCADE,
  CONSTRAINT `evaluaciones_indices_ibfk_2` FOREIGN KEY (`id_profesor`) REFERENCES `profesores` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla gestiondeestudiantes.evaluaciones_indices: ~2 rows (aproximadamente)
INSERT INTO `evaluaciones_indices` (`id`, `id_indice`, `id_profesor`, `porcentaje_dominio`, `comentario`, `fecha_evaluacion`) VALUES
	(1, 1, 1, 50.00, 'El 50% del curso número 50 fue establecido con un índice del 50% por promedio general del aula', '2025-12-04 09:58:40'),
	(2, 2, 1, 70.00, 'El 70% de la clase cumplió con el índice de aprendizaje numero 1', '2025-12-04 10:52:14');

-- Volcando estructura para tabla gestiondeestudiantes.eventos
DROP TABLE IF EXISTS `eventos`;
CREATE TABLE IF NOT EXISTS `eventos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_estudiante` int(11) NOT NULL,
  `titulo` varchar(255) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `fecha` date NOT NULL,
  `hora_inicio` time NOT NULL,
  `hora_fin` time NOT NULL,
  `color` varchar(7) DEFAULT '#4facfe',
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_estudiante` (`id_estudiante`),
  KEY `idx_fecha` (`fecha`),
  KEY `idx_estudiante_fecha` (`id_estudiante`,`fecha`),
  CONSTRAINT `eventos_ibfk_1` FOREIGN KEY (`id_estudiante`) REFERENCES `estudiantes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla gestiondeestudiantes.eventos: ~2 rows (aproximadamente)
INSERT INTO `eventos` (`id`, `id_estudiante`, `titulo`, `descripcion`, `fecha`, `hora_inicio`, `hora_fin`, `color`, `creado_en`, `actualizado_en`) VALUES
	(1, 1, 'SPRINT 2', 'ENTREGA FINAL, PROYECTO INTEGRADOR', '2025-12-05', '05:00:00', '17:00:00', '#9775fa', '2025-12-04 10:01:00', '2025-12-04 10:01:38'),
	(2, 1, 'evaluación de química', 'evaluación final de química', '2025-12-06', '06:00:00', '08:00:00', '#20c997', '2025-12-04 10:57:34', '2025-12-04 10:57:34'),
	(3, 1, 'Comprar materiales', 'Las materias', '2025-12-05', '10:09:00', '11:09:00', '#51cf66', '2025-12-05 15:09:40', '2025-12-05 15:09:40');

-- Volcando estructura para procedimiento gestiondeestudiantes.generar_notificaciones_contenido_vencido
DROP PROCEDURE IF EXISTS `generar_notificaciones_contenido_vencido`;
DELIMITER //
CREATE PROCEDURE `generar_notificaciones_contenido_vencido`()
BEGIN
    DECLARE v_id_profesor INT;
    DECLARE v_id_materia INT;
    DECLARE v_materia_nombre VARCHAR(100);
    DECLARE done INT DEFAULT FALSE;
    DECLARE cursor_profesores CURSOR FOR
        SELECT pac.id_profesor, pac.id_materia, m.nombre
        FROM profesor_actualizaciones_contenido pac
        JOIN materias m ON pac.id_materia = m.id
        WHERE pac.notificacion_enviada = FALSE
        AND DATEDIFF(CURDATE(), DATE(pac.ultima_actualizacion)) >= 3;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cursor_profesores;

    leer_registros: LOOP
        FETCH cursor_profesores INTO v_id_profesor, v_id_materia, v_materia_nombre;
        IF done THEN
            LEAVE leer_registros;
        END IF;

        -- Crear notificación para el profesor
        INSERT INTO notificaciones (
            id_profesor,
            id_estudiante,
            titulo,
            mensaje,
            leida,
            fecha
        ) VALUES (
            v_id_profesor,
            NULL,  -- NULL porque es notificación al profesor, no a un estudiante específico
            CONCAT('Contenido desactualizado: ', v_materia_nombre),
            CONCAT(
                'Hace más de 3 días no actualizas el contenido de la materia "',
                v_materia_nombre,
                '". Por favor, sube material actualizado para mantener a tus estudiantes informados.'
            ),
            FALSE,
            CURRENT_TIMESTAMP
        );

        -- Marcar como enviada
        UPDATE profesor_actualizaciones_contenido
        SET notificacion_enviada = TRUE,
            fecha_notificacion = CURRENT_TIMESTAMP
        WHERE id_profesor = v_id_profesor
        AND id_materia = v_id_materia;

    END LOOP;

    CLOSE cursor_profesores;

END//
DELIMITER ;

-- Volcando estructura para tabla gestiondeestudiantes.horarios
DROP TABLE IF EXISTS `horarios`;
CREATE TABLE IF NOT EXISTS `horarios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_estudiante` int(11) NOT NULL,
  `id_profesor` int(11) NOT NULL,
  `dia_semana` enum('Lunes','Martes','Miércoles','Jueves','Viernes','Sábado','Domingo') NOT NULL,
  `hora_inicio` time NOT NULL,
  `hora_fin` time NOT NULL,
  `id_materia` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `id_estudiante` (`id_estudiante`),
  KEY `id_profesor` (`id_profesor`),
  KEY `id_materia` (`id_materia`),
  CONSTRAINT `horarios_ibfk_1` FOREIGN KEY (`id_estudiante`) REFERENCES `estudiantes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `horarios_ibfk_2` FOREIGN KEY (`id_profesor`) REFERENCES `profesores` (`id`) ON DELETE CASCADE,
  CONSTRAINT `horarios_ibfk_3` FOREIGN KEY (`id_materia`) REFERENCES `materias` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla gestiondeestudiantes.horarios: ~2 rows (aproximadamente)
INSERT INTO `horarios` (`id`, `id_estudiante`, `id_profesor`, `dia_semana`, `hora_inicio`, `hora_fin`, `id_materia`) VALUES
	(1, 1, 1, 'Lunes', '06:00:00', '08:00:00', 1),
	(2, 1, 1, 'Miércoles', '16:00:00', '18:00:00', 2),
	(3, 4, 1, 'Viernes', '06:20:00', '08:40:00', 3),
	(4, 1, 2, 'Miércoles', '09:13:00', '22:13:00', 3);

-- Volcando estructura para tabla gestiondeestudiantes.indices_aprendizaje
DROP TABLE IF EXISTS `indices_aprendizaje`;
CREATE TABLE IF NOT EXISTS `indices_aprendizaje` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_materia` int(11) NOT NULL,
  `id_profesor` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `descripcion` varchar(500) DEFAULT NULL,
  `porcentaje` decimal(5,2) NOT NULL DEFAULT 0.00,
  `parcial` varchar(50) DEFAULT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_indice_profesor_materia` (`id_profesor`,`id_materia`,`nombre`),
  KEY `idx_indices_materia_profesor` (`id_materia`,`id_profesor`),
  CONSTRAINT `indices_aprendizaje_ibfk_1` FOREIGN KEY (`id_materia`) REFERENCES `materias` (`id`) ON DELETE CASCADE,
  CONSTRAINT `indices_aprendizaje_ibfk_2` FOREIGN KEY (`id_profesor`) REFERENCES `profesores` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla gestiondeestudiantes.indices_aprendizaje: ~2 rows (aproximadamente)
INSERT INTO `indices_aprendizaje` (`id`, `id_materia`, `id_profesor`, `nombre`, `descripcion`, `porcentaje`, `parcial`, `fecha_creacion`) VALUES
	(1, 1, 1, 'Resolución de problemas tecnicos', 'Índice de aprendizaje básico sobre la materia establecida ', 30.00, 'Parcial 1', '2025-12-04 09:57:38'),
	(2, 2, 1, 'índice de aprendizaje numero 1', 'Encargado de la parte cognitiva y cambios desarrollados en el aula de clase ', 30.00, 'Parcial 1', '2025-12-04 10:51:14');

-- Volcando estructura para tabla gestiondeestudiantes.inscripciones
DROP TABLE IF EXISTS `inscripciones`;
CREATE TABLE IF NOT EXISTS `inscripciones` (
  `id_estudiante` int(11) NOT NULL,
  `id_materia` int(11) NOT NULL,
  PRIMARY KEY (`id_estudiante`,`id_materia`),
  KEY `id_materia` (`id_materia`),
  CONSTRAINT `inscripciones_ibfk_1` FOREIGN KEY (`id_estudiante`) REFERENCES `estudiantes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `inscripciones_ibfk_2` FOREIGN KEY (`id_materia`) REFERENCES `materias` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla gestiondeestudiantes.inscripciones: ~7 rows (aproximadamente)
INSERT INTO `inscripciones` (`id_estudiante`, `id_materia`) VALUES
	(1, 1),
	(1, 2),
	(2, 1),
	(2, 2),
	(2, 3),
	(3, 2),
	(4, 2);

-- Volcando estructura para tabla gestiondeestudiantes.materias
DROP TABLE IF EXISTS `materias`;
CREATE TABLE IF NOT EXISTS `materias` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `descripcion` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla gestiondeestudiantes.materias: ~2 rows (aproximadamente)
INSERT INTO `materias` (`id`, `nombre`, `descripcion`) VALUES
	(1, 'Matemáticas', 'Clase básica de matemáticas y calculo'),
	(2, 'Química', 'Clase básica de Química'),
	(3, 'Religión ', 'Clase de ética y religión');

-- Volcando estructura para tabla gestiondeestudiantes.mensajes
DROP TABLE IF EXISTS `mensajes`;
CREATE TABLE IF NOT EXISTS `mensajes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_notificacion` int(11) NOT NULL,
  `id_estudiante` int(11) NOT NULL,
  `id_profesor` int(11) NOT NULL,
  `id_materia` int(11) DEFAULT NULL,
  `remitente_tipo` enum('estudiante','profesor') NOT NULL,
  `contenido` text NOT NULL,
  `leido` tinyint(1) DEFAULT 0,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `id_profesor` (`id_profesor`),
  KEY `id_materia` (`id_materia`),
  KEY `idx_notificacion` (`id_notificacion`),
  KEY `idx_estudiante_profesor` (`id_estudiante`,`id_profesor`),
  KEY `idx_leido` (`leido`),
  KEY `idx_fecha` (`fecha`),
  CONSTRAINT `mensajes_ibfk_1` FOREIGN KEY (`id_notificacion`) REFERENCES `notificaciones` (`id`) ON DELETE CASCADE,
  CONSTRAINT `mensajes_ibfk_2` FOREIGN KEY (`id_estudiante`) REFERENCES `estudiantes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `mensajes_ibfk_3` FOREIGN KEY (`id_profesor`) REFERENCES `profesores` (`id`) ON DELETE CASCADE,
  CONSTRAINT `mensajes_ibfk_4` FOREIGN KEY (`id_materia`) REFERENCES `materias` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla gestiondeestudiantes.mensajes: ~3 rows (aproximadamente)
INSERT INTO `mensajes` (`id`, `id_notificacion`, `id_estudiante`, `id_profesor`, `id_materia`, `remitente_tipo`, `contenido`, `leido`, `fecha`) VALUES
	(1, 3, 1, 1, 1, 'estudiante', 'muchas gracias profe por avisar', 0, '2025-12-04 10:56:22'),
	(2, 6, 1, 1, 1, 'estudiante', 'muchas gracias docente', 0, '2025-12-04 14:18:34'),
	(3, 7, 1, 1, 1, 'estudiante', 'muchas docente', 0, '2025-12-04 14:35:28');

-- Volcando estructura para tabla gestiondeestudiantes.notas
DROP TABLE IF EXISTS `notas`;
CREATE TABLE IF NOT EXISTS `notas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_estudiante` int(11) NOT NULL,
  `id_profesor` int(11) NOT NULL,
  `id_materia` int(11) NOT NULL,
  `tipo_evaluacion` varchar(50) NOT NULL DEFAULT 'parcial',
  `nota` decimal(5,2) NOT NULL,
  `comentario` text DEFAULT NULL,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_evaluacion` (`id_estudiante`,`id_materia`,`tipo_evaluacion`,`id_profesor`),
  KEY `id_profesor` (`id_profesor`),
  KEY `id_materia` (`id_materia`),
  CONSTRAINT `notas_ibfk_1` FOREIGN KEY (`id_estudiante`) REFERENCES `estudiantes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `notas_ibfk_2` FOREIGN KEY (`id_profesor`) REFERENCES `profesores` (`id`) ON DELETE CASCADE,
  CONSTRAINT `notas_ibfk_3` FOREIGN KEY (`id_materia`) REFERENCES `materias` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla gestiondeestudiantes.notas: ~7 rows (aproximadamente)
INSERT INTO `notas` (`id`, `id_estudiante`, `id_profesor`, `id_materia`, `tipo_evaluacion`, `nota`, `comentario`, `fecha`) VALUES
	(1, 1, 1, 1, 'Tarea', 3.00, '', '2025-12-04 14:32:23'),
	(2, 1, 1, 2, 'Parcial 1', 5.00, '', '2025-12-04 14:14:19'),
	(3, 3, 1, 2, 'Parcial 1', 2.00, '', '2025-12-04 14:14:19'),
	(4, 4, 1, 2, 'Parcial 1', 3.00, '', '2025-12-04 14:14:19'),
	(5, 2, 1, 2, 'Parcial 1', 4.00, '', '2025-12-04 14:14:19'),
	(6, 1, 1, 1, 'Quiz', 2.00, '', '2025-12-04 14:31:57'),
	(7, 2, 1, 1, 'Tarea', 4.00, '', '2025-12-04 14:32:23');

-- Volcando estructura para tabla gestiondeestudiantes.notificaciones
DROP TABLE IF EXISTS `notificaciones`;
CREATE TABLE IF NOT EXISTS `notificaciones` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_estudiante` int(11) NOT NULL,
  `id_profesor` int(11) NOT NULL,
  `titulo` varchar(255) NOT NULL,
  `mensaje` text NOT NULL,
  `leida` tinyint(1) DEFAULT 0,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_estudiante` (`id_estudiante`),
  KEY `idx_profesor` (`id_profesor`),
  KEY `idx_leida` (`leida`),
  KEY `idx_fecha` (`fecha`),
  CONSTRAINT `notificaciones_ibfk_1` FOREIGN KEY (`id_estudiante`) REFERENCES `estudiantes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `notificaciones_ibfk_2` FOREIGN KEY (`id_profesor`) REFERENCES `profesores` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla gestiondeestudiantes.notificaciones: ~7 rows (aproximadamente)
INSERT INTO `notificaciones` (`id`, `id_estudiante`, `id_profesor`, `titulo`, `mensaje`, `leida`, `fecha`) VALUES
	(1, 1, 1, 'Recordatorio de tarea', 'No se le olvide la tarea para el día miercoles', 1, '2025-12-04 09:56:33'),
	(2, 1, 1, 'Recordatorio de tarea', 'Recuerde que debe de hacer la tarea en el tiempo establecido', 1, '2025-12-04 10:49:19'),
	(3, 1, 1, 'Próximo examen', 'nota de próximo examen para la fecha 5 de diciembre', 1, '2025-12-04 10:49:59'),
	(4, 3, 1, 'Próximo examen', 'nota de próximo examen para la fecha 5 de diciembre', 0, '2025-12-04 10:49:59'),
	(5, 4, 1, 'Próximo examen', 'nota de próximo examen para la fecha 5 de diciembre', 0, '2025-12-04 10:49:59'),
	(6, 1, 1, 'SPRINT 2', 'recuerde el sprint', 1, '2025-12-04 14:15:13'),
	(7, 1, 1, 'Recordatorio de tarea', 'no se olvide la tarea\r\n', 1, '2025-12-04 14:32:46');

-- Volcando estructura para tabla gestiondeestudiantes.padres
DROP TABLE IF EXISTS `padres`;
CREATE TABLE IF NOT EXISTS `padres` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `correo` varchar(100) NOT NULL,
  `contraseña` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `correo` (`correo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla gestiondeestudiantes.padres: ~0 rows (aproximadamente)

-- Volcando estructura para tabla gestiondeestudiantes.padres_estudiantes
DROP TABLE IF EXISTS `padres_estudiantes`;
CREATE TABLE IF NOT EXISTS `padres_estudiantes` (
  `id_padre` int(11) NOT NULL,
  `id_estidente` int(11) NOT NULL,
  PRIMARY KEY (`id_padre`,`id_estidente`),
  KEY `id_estidente` (`id_estidente`),
  CONSTRAINT `padres_estudiantes_ibfk_1` FOREIGN KEY (`id_padre`) REFERENCES `padres` (`id`) ON DELETE CASCADE,
  CONSTRAINT `padres_estudiantes_ibfk_2` FOREIGN KEY (`id_estidente`) REFERENCES `estudiantes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla gestiondeestudiantes.padres_estudiantes: ~0 rows (aproximadamente)

-- Volcando estructura para tabla gestiondeestudiantes.plantillas
DROP TABLE IF EXISTS `plantillas`;
CREATE TABLE IF NOT EXISTS `plantillas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla gestiondeestudiantes.plantillas: ~0 rows (aproximadamente)

-- Volcando estructura para tabla gestiondeestudiantes.profesores
DROP TABLE IF EXISTS `profesores`;
CREATE TABLE IF NOT EXISTS `profesores` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `correo` varchar(100) NOT NULL,
  `contraseña` varchar(255) NOT NULL,
  `hoja_vida` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `correo` (`correo`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla gestiondeestudiantes.profesores: ~3 rows (aproximadamente)
INSERT INTO `profesores` (`id`, `nombre`, `correo`, `contraseña`, `hoja_vida`) VALUES
	(1, 'Jaime Rodriguez', 'jaime@gmail.com', 'scrypt:32768:8:1$Too5veyI6yLP6XiW$a1be6b827c1130471a5aafa19fbba82d0dc7bd4b5c35bdac532c1e0fcfa3a24179e5550730b0c6763fd7ed04b4cfb7c9091d141c3fe795f2cc90ed8b068c9326', '1_1764845607_Hoja_de_vida_pdf.pdf'),
	(2, 'Ayde gonzalez', 'gonzalez@gmail.com', 'scrypt:32768:8:1$paEDQF6T2pAdBjym$2ec94d6e796b3dfcb39dcede87bc1f24c17c9d516ca682791f7304204a847fab41499f85a7dbb093238335bcad4288eb8b192bc5b781bc5777d48eaa005b9c24', NULL),
	(3, 'luis lasso', 'lasso@gmail.com', 'scrypt:32768:8:1$l7jEc7girzWP5DEl$2d93bbbda7520cdb1d810ad695acab958b35153b021d3bd8a846604049e25d7bc39a2a141fd9889da7e58cf984c357be63550cb05738fd02021dba2f717df271', NULL);

-- Volcando estructura para tabla gestiondeestudiantes.tareas
DROP TABLE IF EXISTS `tareas`;
CREATE TABLE IF NOT EXISTS `tareas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_estudiante` int(11) NOT NULL,
  `titulo` varchar(255) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `fecha_entrega` datetime NOT NULL,
  `estado` enum('pendiente','entregada','vencida') DEFAULT 'pendiente',
  PRIMARY KEY (`id`),
  KEY `id_estudiante` (`id_estudiante`),
  CONSTRAINT `tareas_ibfk_1` FOREIGN KEY (`id_estudiante`) REFERENCES `estudiantes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla gestiondeestudiantes.tareas: ~0 rows (aproximadamente)

-- Volcando estructura para tabla gestiondeestudiantes.tareas_materia
DROP TABLE IF EXISTS `tareas_materia`;
CREATE TABLE IF NOT EXISTS `tareas_materia` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_profesor` int(11) NOT NULL,
  `id_materia` int(11) NOT NULL,
  `titulo` varchar(255) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `tipo_tarea` varchar(50) NOT NULL,
  `fecha_entrega` datetime NOT NULL,
  `filename` varchar(255) DEFAULT NULL,
  `mimetype` varchar(100) DEFAULT NULL,
  `ruta` varchar(500) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_tareas_materia_profesor` (`id_profesor`),
  KEY `idx_tareas_materia_materia` (`id_materia`),
  KEY `idx_tareas_materia_fecha` (`fecha_entrega`),
  CONSTRAINT `tareas_materia_ibfk_1` FOREIGN KEY (`id_profesor`) REFERENCES `profesores` (`id`) ON DELETE CASCADE,
  CONSTRAINT `tareas_materia_ibfk_2` FOREIGN KEY (`id_materia`) REFERENCES `materias` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla gestiondeestudiantes.tareas_materia: ~0 rows (aproximadamente)
INSERT INTO `tareas_materia` (`id`, `id_profesor`, `id_materia`, `titulo`, `descripcion`, `tipo_tarea`, `fecha_entrega`, `filename`, `mimetype`, `ruta`, `creado_en`, `actualizado_en`) VALUES
	(1, 1, 1, 'TALLER MATEMÁTICAS', 'Elaborar el taller en el tiempo establecido', 'tarea', '2025-12-08 14:00:00', '1_1764909501_UNIVALLE_-_FACN_-_Taller_1_-_20252_1.pdf', 'application/pdf', 'uploads/contenidos/1/1_1764909501_UNIVALLE_-_FACN_-_Taller_1_-_20252_1.pdf', '2025-12-05 04:38:21', '2025-12-05 04:38:21'),
	(2, 1, 2, 'Recordatorio de tarea', 'Clase basica de matematicas', 'tarea', '2025-12-15 22:05:00', '1_1764947177_Taller_Practico_Accesibilidad_Web_Jairo_Rodriguez_Proyecto_Integrador.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'uploads/contenidos/1/1_1764947177_Taller_Practico_Accesibilidad_Web_Jairo_Rodriguez_Proyecto_Integrador.docx', '2025-12-05 15:06:17', '2025-12-05 15:06:17');

-- Volcando estructura para tabla gestiondeestudiantes.usuarios
DROP TABLE IF EXISTS `usuarios`;
CREATE TABLE IF NOT EXISTS `usuarios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `correo` varchar(100) NOT NULL,
  `contraseña` varchar(255) NOT NULL,
  `rol` enum('admin','profesor','estudiante','padre') NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `correo` (`correo`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla gestiondeestudiantes.usuarios: ~8 rows (aproximadamente)
INSERT INTO `usuarios` (`id`, `nombre`, `correo`, `contraseña`, `rol`) VALUES
	(1, 'admin', 'admin@gmail.com', 'scrypt:32768:8:1$uiQOVWHGd2vGFW83$45db538c5a90cd3a96ed826ebb12e604ac32f9ff177e84dac40c67b3c7a5bf02cce1e092ba3fb604d8bb924d34261dc5f8f0c14632b46b8d6ca22640ecebe777', 'admin'),
	(2, 'kevin cuero', 'cuero@gmail.com', 'scrypt:32768:8:1$y0X38a2o4opf2SAS$0ff81e22b744105af48ff772f047d376097e25d4b724d8057d84af8c9893de7d5cacf6d258eb8b014ba7c9efdd44b499bc1ef93f76b377b5ada2218dbd94752f', 'estudiante'),
	(3, 'Jaime Rodriguez', 'jaime@gmail.com', 'scrypt:32768:8:1$Too5veyI6yLP6XiW$a1be6b827c1130471a5aafa19fbba82d0dc7bd4b5c35bdac532c1e0fcfa3a24179e5550730b0c6763fd7ed04b4cfb7c9091d141c3fe795f2cc90ed8b068c9326', 'profesor'),
	(4, 'zharick cuero', 'zharick@gmail.com', 'scrypt:32768:8:1$YjGraxc45Oedou2x$8c4d75ad75b856039603685d5597475b671a37c71158b2f17883256fbeddd4faa144db1c21127c353cc2183ed351d954d820bca8332d1664ab52f6f6eb4d921f', 'estudiante'),
	(5, 'kevin marin', 'marin@gmail.com', 'scrypt:32768:8:1$W1EXF1CkgYE1yxxy$148300fe597250154b61551b29fc273e0c96f294dc776095f33fbbe9ec20c0c2e97563813863d53889625504820251868e27909342d07aa1d4443edf75a71012', 'estudiante'),
	(6, 'juan naranjo', 'naranjo@gmail.com', 'scrypt:32768:8:1$itfycU53aCtX44JJ$998eab97c0bbd5301147c57ff44c388fc3b3782163e01b12d17f3b1b19ed0b06a31cb3ad50ede36f18ba56b45b3d12d7ed3c15ca33f75b2e8b187e41f51800aa', 'estudiante'),
	(7, 'Ayde gonzalez', 'gonzalez@gmail.com', 'scrypt:32768:8:1$paEDQF6T2pAdBjym$2ec94d6e796b3dfcb39dcede87bc1f24c17c9d516ca682791f7304204a847fab41499f85a7dbb093238335bcad4288eb8b192bc5b781bc5777d48eaa005b9c24', 'profesor'),
	(8, 'luis lasso', 'lasso@gmail.com', 'scrypt:32768:8:1$l7jEc7girzWP5DEl$2d93bbbda7520cdb1d810ad695acab958b35153b021d3bd8a846604049e25d7bc39a2a141fd9889da7e58cf984c357be63550cb05738fd02021dba2f717df271', 'profesor');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
