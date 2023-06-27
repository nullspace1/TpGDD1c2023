USE [GD1C2023]

IF EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'BI')
BEGIN
    DECLARE @sql NVARCHAR(MAX) = N'';

    -- Drop foreign keys
    SELECT @sql += N'
    ALTER TABLE [' + OBJECT_SCHEMA_NAME(fk.parent_object_id) + N'].[' + OBJECT_NAME(fk.parent_object_id) + N']
    DROP CONSTRAINT [' + fk.name + N'];'
    FROM sys.foreign_keys AS fk
    JOIN sys.tables AS t ON fk.parent_object_id = t.object_id
    WHERE SCHEMA_NAME(t.schema_id) = N'BI';

    -- Drop tables
    SELECT @sql += N'
    DROP TABLE [' + SCHEMA_NAME(schema_id) + N'].[' + name + N'];'
    FROM sys.tables
    WHERE SCHEMA_NAME(schema_id) = N'BI';

    -- Drop views
    SELECT @sql += N'
    DROP VIEW [' + SCHEMA_NAME(schema_id) + N'].[' + name + N'];'
    FROM sys.views
    WHERE SCHEMA_NAME(schema_id) = N'BI';

    -- Drop schema
    SET @sql += N'DROP SCHEMA [BI];';

    -- Execute the SQL
    EXEC sp_executesql @sql;
END
GO


CREATE SCHEMA [BI]
GO
CREATE TABLE BI.MES (
  id INT IDENTITY(1,1),
  año INT,
  mes INT,
  PRIMARY KEY (id)
);

CREATE TABLE BI.DIA (
  id INT IDENTITY(1,1),
  dia_de_semana NVARCHAR(50),
  PRIMARY KEY (id)
);

CREATE TABLE BI.RANGO_HORARIO (
  id INT IDENTITY(1,1),
  rango_horario_inicio DECIMAL(18,0),
  rango_horario_fin DECIMAL(18,0),
  PRIMARY KEY (id)
);

CREATE TABLE BI.RANGO_ETARIO (
  id INT IDENTITY(1,1),
  rango_etario_inicio INT,
  rango_etario_fin INT,
  PRIMARY KEY (id)
);

CREATE TABLE BI.LOCALIDAD (
  id INT,
  nombre_localidad NVARCHAR(255),
  nombre_provincia NVARCHAR(255),
  PRIMARY KEY (id)
);



CREATE TABLE BI.TIPO_LOCAL (
  id INT,
  tipo_local NVARCHAR(50),
  PRIMARY KEY (id)
);

CREATE TABLE BI.CATEGORIA_LOCAL (
  id INT,
  categoria_local NVARCHAR(50),
  tipo_id INT,
  PRIMARY KEY(id),
  FOREIGN KEY (tipo_id) REFERENCES BI.TIPO_LOCAL (id)
);

CREATE TABLE BI.LOCAL (
  id INT,
  nombre_local NVARCHAR(255),
  descripcion_local NVARCHAR(255),
  localidad_id INT,
  categoria_local_id INT,
  PRIMARY KEY (id),
  FOREIGN KEY (localidad_id) REFERENCES BI.LOCALIDAD (id),
  FOREIGN KEY (categoria_local_id) REFERENCES BI.CATEGORIA_LOCAL (id)
);

CREATE TABLE BI.TIPO_MOVILIDAD (
  id INT,
  tipo_movilidad NVARCHAR(50),
  PRIMARY KEY (id)
);

CREATE TABLE BI.TIPO_PAQUETE (
  id INT,
  tipo_paquete NVARCHAR(50),
  PRIMARY KEY (id)
);


CREATE TABLE BI.TIPO_RECLAMO (
  id INT,
  tipo_reclamo NVARCHAR(50),
  PRIMARY KEY (id)
);

CREATE TABLE BI.ESTADO_PEDIDO (
  id INT,
  estado_pedido NVARCHAR(50),
  PRIMARY KEY(id)
);

CREATE TABLE BI.ESTADISTICAS_PEDIDOS (
    id INT IDENTITY(1,1),
    local_id INT,
    anio_mes_id INT,
    franja_horaria_id INT,
    dia_semana_id INT,
    estado_pedido_id INT,
    cantidad_pedidos INT,
    valor_total DECIMAL(18,2),
    PRIMARY KEY (id),
    FOREIGN KEY (local_id) REFERENCES BI.LOCAL (id),
    FOREIGN KEY (anio_mes_id) REFERENCES BI.MES (id),
    FOREIGN KEY (franja_horaria_id) REFERENCES BI.RANGO_HORARIO (id),
    FOREIGN KEY (dia_semana_id) REFERENCES BI.DIA (id),
    FOREIGN KEY (estado_pedido_id) REFERENCES BI.ESTADO_PEDIDO (id)
);

CREATE TABLE BI.ESTADISTICAS_ENVIOS_PEDIDOS (
    id INT IDENTITY(1,1),
    anio_mes_id INT,
    localidad_id INT,
    valor_total DECIMAL(18,2),
    PRIMARY KEY (id),
    FOREIGN KEY (anio_mes_id) REFERENCES BI.MES (id),
    FOREIGN KEY (localidad_id) REFERENCES BI.LOCALIDAD (id)
);

CREATE TABLE BI.ESTADISTICAS_ENVIOS_MENSAJERIA (
    id INT IDENTITY(1,1),
    tipo_paquete_id INT,
    anio_mes_id INT,
    valor_promedio DECIMAL(18,2),
    PRIMARY KEY (id),
    FOREIGN KEY (tipo_paquete_id) REFERENCES BI.TIPO_PAQUETE (id),
    FOREIGN KEY (anio_mes_id) REFERENCES BI.MES (id)
);

CREATE TABLE BI.ESTADISTICAS_ENVIOS_TOTAL (
    id INT IDENTITY(1,1),
    tipo_movilidad_id INT,
    dia_semana_id INT,
    franja_horaria_id INT,
    rango_etario_id INT,
    localidad_id INT,
    cantidad_envios INT,
    desvio_tiempo DECIMAL(18,2),
    PRIMARY KEY (id),
    FOREIGN KEY (tipo_movilidad_id) REFERENCES BI.TIPO_MOVILIDAD (id),
    FOREIGN KEY (dia_semana_id) REFERENCES BI.DIA (id),
    FOREIGN KEY (franja_horaria_id) REFERENCES BI.RANGO_HORARIO (id),
    FOREIGN KEY (rango_etario_id) REFERENCES BI.RANGO_ETARIO (id),
    FOREIGN KEY (localidad_id) REFERENCES BI.LOCALIDAD (id)
);

CREATE TABLE BI.ESTADISTICAS_LOCAL (
    id INT IDENTITY(1,1),
    local_id INT,
    mes_anio_id INT,
    dia_semana_reclamo_id INT,
    rango_horario_id INT,
    cantidad_reclamos INT,
    calificacion_promedio DECIMAL(18,0),
    PRIMARY KEY (id),
    FOREIGN KEY (local_id) REFERENCES BI.LOCAL (id),
    FOREIGN KEY (mes_anio_id) REFERENCES BI.MES (id),
    FOREIGN KEY (dia_semana_reclamo_id) REFERENCES BI.DIA (id),
    FOREIGN KEY (rango_horario_id) REFERENCES BI.RANGO_HORARIO (id)
);

CREATE TABLE BI.ESTADISTICAS_RECLAMOS (
    id INT IDENTITY(1,1),
    mes_anio_id INT,
    dia_semana_id INT,
    rango_horario_id INT,
    tipo_reclamo_id INT,
    rango_etario_operador_id INT,
    cantidad_reclamos INT,
    monto_mensual_cupones DECIMAL(18,2),
    tiempo_resolucion DECIMAL(18,2),
    PRIMARY KEY (id),
    FOREIGN KEY (mes_anio_id) REFERENCES BI.MES (id),
    FOREIGN KEY (dia_semana_id) REFERENCES BI.DIA (id),
    FOREIGN KEY (rango_horario_id) REFERENCES BI.RANGO_HORARIO (id),
    FOREIGN KEY (tipo_reclamo_id) REFERENCES BI.TIPO_RECLAMO (id),
    FOREIGN KEY (rango_etario_operador_id) REFERENCES BI.RANGO_ETARIO (id)
);

CREATE TABLE BI.ESTADISTICAS_CUPONES (
    id INT IDENTITY(1,1),
    monto_total_cupones DECIMAL(18,2),
    rango_etario_usuario_id INT,
    PRIMARY KEY (id),
    FOREIGN KEY (rango_etario_usuario_id) REFERENCES BI.RANGO_ETARIO (id)
);



INSERT INTO BI.MES (mes, año)
VALUES
(1, 2023),
(2, 2023),
(3, 2023),
(4, 2023),
(5, 2023),
(6, 2023),
(7, 2023),
(8, 2023),
(9, 2023),
(10, 2023),
(11, 2023),
(12, 2023),
(1, 2024),
(2, 2024),
(3, 2024),
(4, 2024),
(5, 2024),
(6, 2024),
(7, 2024),
(8, 2024),
(9, 2024),
(10, 2024),
(11, 2024),
(12, 2024);


INSERT INTO BI.DIA (dia_de_semana) VALUES
('LUNES'),
('MARTES'),
('MIERCOLES'),
('JUEVES'),
('VIERNES'),
('SABADO'),
('DOMINGO');


INSERT INTO BI.RANGO_ETARIO (rango_etario_inicio, rango_etario_fin)
VALUES
(0, 24),
(25, 35),
(35, 55),
(56, 999);


INSERT INTO BI.RANGO_HORARIO (rango_horario_inicio, rango_horario_fin)
VALUES
(8, 10),
(10, 12),
(12, 14),
(14, 16),
(16, 18),
(18, 20),
(20, 22),
(22, 24);

INSERT INTO BI.TIPO_LOCAL (id,tipo_local)
SELECT
TL.id_tipo_local,
TL.tipo
FROM
ESECUELE.TIPO_LOCAL TL

INSERT INTO BI.CATEGORIA_LOCAL (id,categoria_local,tipo_id)
SELECT DISTINCT
CL.id_categoria_local,
CL.categoria,
CL.tipo_local_id
FROM ESECUELE.LOCAL L
JOIN ESECUELE.TIPO_LOCAL TL ON L.tipo_local_id = TL.id_tipo_local
JOIN ESECUELE.CATEGORIA_LOCAL CL ON L.categoria_local_id = CL.id_categoria_local;


INSERT INTO BI.ESTADO_PEDIDO (id,estado_pedido)
SELECT DISTINCT
EP.id_estado_pedido,
EP.estado
FROM
ESECUELE.ESTADO_PEDIDO EP


INSERT INTO BI.TIPO_MOVILIDAD (id,tipo_movilidad)
SELECT DISTINCT
id_tipo_movilidad,
nombre
FROM
ESECUELE.TIPO_MOVILIDAD;


INSERT INTO BI.TIPO_PAQUETE (id, tipo_paquete)
SELECT DISTINCT id_tipo_paquete, tipo
FROM ESECUELE.TIPO_PAQUETE;

INSERT INTO BI.TIPO_RECLAMO (id,tipo_reclamo)
SELECT DISTINCT
TR.id_tipo_reclamo,
TR.tipo
FROM ESECUELE.TIPO_RECLAMO TR




INSERT INTO BI.LOCALIDAD (id,nombre_localidad,nombre_provincia)
SELECT
id_localidad,
L.nombre,
P.nombre
FROM ESECUELE.LOCALIDAD L
JOIN ESECUELE.PROVINCIA P ON L.id_localidad = P.id_provincia




INSERT INTO BI.LOCAL (id, nombre_local, descripcion_local, localidad_id,categoria_local_id)
SELECT
id_local,
nombre,
descripcion,
localidad_id,
categoria_local_id
FROM ESECUELE.LOCAL LO
JOIN BI.LOCALIDAD L ON LO.localidad_id = L.id
GO

CREATE FUNCTION FRANJA_HORARIA (@fecha DATETIME)
RETURNS INT
AS

BEGIN
RETURN
(SELECT
BI.RANGO_HORARIO.id
FROM
BI.RANGO_HORARIO
WHERE
 BI.RANGO_HORARIO.rango_horario_inicio <= DATEPART(HOUR, @fecha)
            AND DATEPART(HOUR, @fecha) < BI.RANGO_HORARIO.rango_horario_fin
)
END
GO

CREATE FUNCTION RANGO_ETARIO(@fecha_nac DATE)
RETURNS INT
AS
BEGIN
    DECLARE @fecha_actual DATE = GETDATE()
    DECLARE @anios INT = YEAR(@fecha_actual) - YEAR(@fecha_nac)

    IF MONTH(@fecha_actual) < MONTH(@fecha_nac) OR (MONTH(@fecha_actual) = MONTH(@fecha_nac) AND DAY(@fecha_actual) < DAY(@fecha_nac))
        SET @anios = @anios - 1

    RETURN (SELECT TOP 1 RE.id FROM BI.RANGO_ETARIO RE WHERE RE.rango_etario_inicio <= @anios AND RE.rango_etario_fin >= @anios)
END
GO

CREATE FUNCTION MES_ANIO_ID
(
    @fecha_hora_pedido DATETIME
)
RETURNS INT
AS
BEGIN
    DECLARE @mesId INT;

    SELECT @mesId = id
    FROM BI.MES
    WHERE año = YEAR(@fecha_hora_pedido) AND mes = MONTH(@fecha_hora_pedido);

    RETURN @mesId;
END;
GO

INSERT INTO BI.ESTADISTICAS_PEDIDOS(local_id,anio_mes_id, franja_horaria_id, dia_semana_id, cantidad_pedidos, valor_total,estado_pedido_id)
SELECT
    L.id,
	dbo.MES_ANIO_ID(ESECUELE.PEDIDO.fecha_pedido),
    dbo.FRANJA_HORARIA(ESECUELE.PEDIDO.fecha_pedido) AS franja_horaria_id,
    DATEPART(weekday, ESECUELE.PEDIDO.fecha_pedido) AS dia_semana_id,
    COUNT(*) AS cantidad_pedidos,
    SUM(total_pedido - ISNULL(total_cupones, 0)) AS valor_total,
	ESECUELE.PEDIDO.estado_pedido_id
FROM
    ESECUELE.PEDIDO
	JOIN
	BI.LOCAL L ON L.id = ESECUELE.PEDIDO.local_id
GROUP BY
    L.id,
    dbo.FRANJA_HORARIA(ESECUELE.PEDIDO.fecha_pedido),
    DATEPART(weekday, ESECUELE.PEDIDO.fecha_pedido),
    estado_pedido_id,
	dbo.MES_ANIO_ID(ESECUELE.PEDIDO.fecha_pedido)



INSERT INTO BI.ESTADISTICAS_ENVIOS_PEDIDOS(anio_mes_id,localidad_id,valor_total)
SELECT
    M.id,
	LI.id,
    SUM(P.total_pedido + E.tarifa_servicio + E.propina - ISNULL(P.total_cupones, 0)) AS valor_total
FROM
    ESECUELE.PEDIDO AS P
    JOIN ESECUELE.ENVIO AS E ON P.id_pedido = E.pedido_id
    JOIN BI.MES AS M ON YEAR(P.fecha_pedido) = M.año AND MONTH(P.fecha_pedido) = M.mes
	JOIN ESECUELE.DIRECCION_USUARIO DU ON DU.id_direccion_usuario = E.direccion_usuario_id
	JOIN BI.LOCALIDAD LI ON LI.id = DU.localidad_id
GROUP BY
M.id,
LI.id


INSERT INTO BI.ESTADISTICAS_ENVIOS_MENSAJERIA(valor_promedio, tipo_paquete_id, anio_mes_id)
SELECT
  AVG(total) AS valor_promedio,
  tipo_paquete_id,
  dbo.MES_ANIO_ID(fecha_hora_pedido)
FROM ESECUELE.ENVIO_MENSAJERIA
GROUP BY
tipo_paquete_id,
dbo.MES_ANIO_ID(fecha_hora_pedido)
GO


INSERT INTO BI.ESTADISTICAS_ENVIOS_TOTAL(tipo_movilidad_id,cantidad_envios, dia_semana_id, franja_horaria_id, desvio_tiempo, rango_etario_id, localidad_id)
SELECT
    id_tipo_movilidad,
	COUNT(*),
    DAY,
    FRANJA,
    AVG(desvio_tiempo),
    fecha_nac,
    LOCALIDAD
FROM
    (
    SELECT
        TM.id_tipo_movilidad,
        DATEPART(weekday,E.fecha_pedido) AS DAY,
        dbo.FRANJA_HORARIA(E.fecha_pedido) AS FRANJA,
        (DATEDIFF(MINUTE, E.fecha_pedido, E.fecha_entrega) - E.tiempo_estimado_entrega) AS desvio_tiempo,
        dbo.RANGO_ETARIO(R.fecha_nac) as fecha_nac,
        L.id_localidad AS LOCALIDAD
    FROM
        ESECUELE.ENVIO E
		    JOIN ESECUELE.PEDIDO P ON P.id_pedido = E.pedido_id
        JOIN ESECUELE.REPARTIDOR R ON R.id_repartidor = E.repartidor_id
        JOIN ESECUELE.DIRECCION_USUARIO DU  ON DU.id_direccion_usuario = E.direccion_usuario_id
        JOIN ESECUELE.LOCALIDAD L ON L.id_localidad = DU.localidad_id
        JOIN ESECUELE.TIPO_MOVILIDAD TM ON TM.id_tipo_movilidad = R.tipo_movilidad_id
		    JOIN BI.LOCALIDAD LI ON LI.id = L.id_localidad
    UNION ALL
    SELECT
        TM.id_tipo_movilidad,
        DATEPART(weekday,EM.fecha_hora_pedido) AS DAY,
        dbo.FRANJA_HORARIA(EM.fecha_hora_pedido) AS FRANJA,
        (DATEDIFF(MINUTE, EM.fecha_hora_pedido, EM.fecha_hora_entrega) - EM.tiempo_estimado) AS desvio_tiempo,
        dbo.RANGO_ETARIO(R.fecha_nac) as fecha_nac,
        L.id_localidad AS LOCALIDAD
    FROM
        ESECUELE.ENVIO_MENSAJERIA EM
        JOIN ESECUELE.REPARTIDOR R ON R.id_repartidor = EM.repartidor_id
        JOIN ESECUELE.LOCALIDAD L ON L.id_localidad = EM.localidad_id
        JOIN ESECUELE.TIPO_MOVILIDAD TM ON TM.id_tipo_movilidad = R.tipo_movilidad_id
		JOIN BI.LOCALIDAD LI ON LI.id = L.id_localidad
        JOIN ESECUELE.ESTADO_ENVIO_MENSAJERIA EEM ON EM.estado_id = EEM.id_estado_envio
    WHERE
        EEM.estado = 'Estado Mensajeria Entregado'
    ) AS UnionQuery
GROUP BY
    id_tipo_movilidad,
    DAY,
    FRANJA,
    fecha_nac,
    LOCALIDAD;

INSERT INTO BI.ESTADISTICAS_LOCAL(local_id,cantidad_reclamos,dia_semana_reclamo_id,calificacion_promedio,mes_anio_id,rango_horario_id)
	SELECT
	L.id,
	SUM(CASE WHEN R.id_reclamo IS NULL THEN 0 ELSE 1 END),
	DATEPART(weekday, R.fecha_hora),
	AVG(P.calificacion),
	dbo.MES_ANIO_ID(P.fecha_pedido),
	dbo.FRANJA_HORARIA(P.fecha_pedido)
	FROM
	BI.LOCAL L
	JOIN ESECUELE.PEDIDO P ON P.local_id = L.id
	LEFT OUTER JOIN ESECUELE.RECLAMO R ON R.pedido_id = P.id_pedido
	GROUP BY
	L.id,
	DATEPART(weekday, R.fecha_hora),
	dbo.MES_ANIO_ID(P.fecha_pedido),
	dbo.FRANJA_HORARIA(P.fecha_pedido)


INSERT INTO BI.ESTADISTICAS_RECLAMOS(cantidad_reclamos,monto_mensual_cupones,mes_anio_id,tiempo_resolucion,dia_semana_id,rango_horario_id,tipo_reclamo_id,rango_etario_operador_id )
	SELECT
	COUNT(*),
	SUM(C.descuento),
	dbo.MES_ANIO_ID(R.fecha_hora),
	AVG(DATEDIFF(MINUTE, R.fecha_hora, R.fecha_hora_solucion)),
	DATEPART(weekday,R.fecha_hora),
	dbo.FRANJA_HORARIA(R.fecha_hora),
	R.tipo_reclamo_id,
	dbo.RANGO_ETARIO(O.fecha_nacimiento)
	FROM
	ESECUELE.RECLAMO R
	JOIN ESECUELE.CUPON_RECLAMO CR ON R.id_reclamo = CR.reclamo_id
	JOIN ESECUELE.CUPON C ON C.id_cupon = CR.cupon_id
	JOIN ESECUELE.OPERADOR O ON O.id_operador = R.operador_id
	GROUP BY
	dbo.MES_ANIO_ID(R.fecha_hora),
	DATEPART(weekday,R.fecha_hora),
	dbo.FRANJA_HORARIA(R.fecha_hora),
	R.tipo_reclamo_id,
	dbo.RANGO_ETARIO(O.fecha_nacimiento)
GO

INSERT INTO BI.ESTADISTICAS_CUPONES
	SELECT
	SUM(C.descuento),
	dbo.RANGO_ETARIO(U.fecha_nac)
	FROM
	ESECUELE.CUPON C
	JOIN ESECUELE.CUPON_USUARIO CU ON C.id_cupon = CU.cupon_id
	JOIN ESECUELE.USUARIO U ON U.id_usuario = CU.usuario_id
	GROUP BY
	dbo.RANGO_ETARIO(U.fecha_nac)
GO

DROP FUNCTION dbo.FRANJA_HORARIA
DROP FUNCTION dbo.RANGO_ETARIO
DROP FUNCTION dbo.MES_ANIO_ID
GO

CREATE VIEW BI.dia_franja_con_mayor_pedidos AS
WITH RankingOrdenes AS (
    SELECT
        D2.dia_de_semana,
		RH2.rango_horario_inicio,
		RH2.rango_horario_fin,
        L2.localidad_id,
        L2.categoria_local_id,
        EP2.anio_mes_id,
        RANK() OVER (PARTITION BY L2.localidad_id, L2.categoria_local_id, EP2.anio_mes_id ORDER BY SUM(ISNULL(EP2.cantidad_pedidos, 0)) DESC) as rank
    FROM
        BI.ESTADISTICAS_PEDIDOS EP2
        JOIN BI.LOCAL L2 ON L2.id = EP2.local_id
        JOIN BI.DIA D2 ON D2.id = EP2.dia_semana_id
        JOIN BI.RANGO_HORARIO RH2 ON RH2.id = EP2.franja_horaria_id
		JOIN BI.LOCALIDAD LO2 ON LO2.id = L2.localidad_id
		JOIN BI.MES M2 ON M2.id = EP2.anio_mes_id
		JOIN BI.CATEGORIA_LOCAL C ON C.id = L2.categoria_local_id
	GROUP BY
	D2.dia_de_semana,
    RH2.rango_horario_inicio,
    RH2.rango_horario_fin,
    L2.localidad_id,
    L2.categoria_local_id,
    EP2.anio_mes_id
)
SELECT
    RO.dia_de_semana,
	RO.rango_horario_inicio,
	RO.rango_horario_fin,
    LO.nombre_localidad,
    C.categoria_local,
    M.mes,
    M.año
FROM
    BI.ESTADISTICAS_PEDIDOS EP
    JOIN BI.LOCAL L ON L.id = EP.local_id
    JOIN BI.LOCALIDAD LO ON LO.id = L.localidad_id
    JOIN BI.RANGO_HORARIO RH ON RH.id = EP.franja_horaria_id
    JOIN BI.MES M ON M.id = EP.anio_mes_id
    JOIN BI.DIA D ON D.id = EP.dia_semana_id
    JOIN BI.CATEGORIA_LOCAL C ON C.id = L.categoria_local_id
    JOIN RankingOrdenes RO ON RO.localidad_id = L.localidad_id
                                AND RO.categoria_local_id = L.categoria_local_id
                                AND RO.anio_mes_id = EP.anio_mes_id
                                AND RO.rank = 1
GROUP BY
    LO.nombre_localidad,
    C.categoria_local,
    M.mes,
    M.año,
    L.categoria_local_id,
    L.localidad_id,
    EP.anio_mes_id,
    RO.dia_de_semana,
	RO.rango_horario_inicio,
	RO.rango_horario_fin
GO

CREATE VIEW BI.monto_total_no_cobrado AS
SELECT
SUM(EP.valor_total) as valor_total_no_cobrado,
D.dia_de_semana as dia,
rango_horario_inicio,
rango_horario_fin
FROM
BI.ESTADISTICAS_PEDIDOS EP
JOIN
BI.ESTADO_PEDIDO EEP ON EEP.id = EP.estado_pedido_id
JOIN
BI.DIA D ON D.id = EP.dia_semana_id
JOIN
BI.RANGO_HORARIO RH ON RH.id = EP.franja_horaria_id
GROUP BY
D.dia_de_semana,
rango_horario_inicio,
rango_horario_fin,
EEP.estado_pedido
HAVING
EEP.estado_pedido = 'Estado Mensajeria Cancelado'
GO

CREATE VIEW BI.valor_promedio_mensual AS
SELECT
AVG(EEP.valor_total) as valor_promedio_mensual,
L.nombre_localidad as localidad
FROM
BI.ESTADISTICAS_ENVIOS_PEDIDOS EEP
JOIN
BI.LOCALIDAD L ON L.id = EEP.localidad_id
GROUP BY
L.nombre_localidad
GO

CREATE VIEW BI.desvio_promedio_tiempo_entrega AS
SELECT
AVG(EET.desvio_tiempo) as desvio_tiempo,
D.dia_de_semana dia_semana,
TM.tipo_movilidad as tipo_movilidad,
RH.rango_horario_inicio as comienzo_rango_horario,
RH.rango_horario_fin as fin_rango_horario
FROM
BI.ESTADISTICAS_ENVIOS_TOTAL EET
JOIN
BI.DIA D ON D.id = EET.dia_semana_id
JOIN
BI.TIPO_MOVILIDAD TM ON TM.id = EET.tipo_movilidad_id
JOIN
BI.RANGO_HORARIO RH ON RH.id = EET.franja_horaria_id
GROUP BY
EET.localidad_id,
D.dia_de_semana,
TM.tipo_movilidad,
RH.rango_horario_inicio ,
RH.rango_horario_fin;
GO

CREATE VIEW BI.monto_total_cupones_utilizados AS
SELECT
EC.monto_total_cupones as monto_total,
RE.rango_etario_inicio as rango_etario_comienzo,
RE.rango_etario_fin as rango_estario_fin
FROM
BI.ESTADISTICAS_CUPONES EC
JOIN
BI.RANGO_ETARIO RE ON RE.id = EC.rango_etario_usuario_id;
GO

CREATE VIEW BI.calificacion_mensual_local AS
SELECT
EL.local_id,
AVG(EL.calificacion_promedio) as calificacion_promedio
FROM
BI.ESTADISTICAS_LOCAL EL
GROUP BY
EL.mes_anio_id,
EL.local_id;
GO

CREATE VIEW BI.pedidos_envios_entregados_mensualmente AS
SELECT
SUM(EET.cantidad_envios) OVER (PARTITION BY EET.localidad_id, EET.rango_etario_id) / (SELECT SUM(EET2.cantidad_envios) FROM BI.ESTADISTICAS_ENVIOS_TOTAL EET2) as porcentage_envios,
RE.rango_etario_inicio as rango_etario_repartidor_comienzo,
RE.rango_etario_fin as rango_etario_repartidor_fin,
L.nombre_localidad as localidad
FROM
BI.ESTADISTICAS_ENVIOS_TOTAL EET
JOIN
BI.RANGO_ETARIO RE ON RE.id = EET.rango_etario_id
JOIN
BI.LOCALIDAD L ON L.id = EET.localidad_id;
GO

CREATE VIEW BI.promedio_mensual_valor_asegurado AS
SELECT
valor_promedio as valor_promedio,
TP.tipo_paquete as tipo_paquete,
M.año as anio,
M.mes as mes
FROM
BI.ESTADISTICAS_ENVIOS_MENSAJERIA EEM
JOIN
BI.TIPO_PAQUETE TP ON TP.id = EEM.tipo_paquete_id
JOIN
BI.MES M ON M.id = EEM.anio_mes_id;
GO

CREATE VIEW BI.cantidad_reclamos_mensuales AS
SELECT
L.nombre_local,
SUM(EL.cantidad_reclamos) as cant_reclamos,
D.dia_de_semana,
RH.rango_horario_inicio,
RH.rango_horario_fin
FROM
BI.ESTADISTICAS_LOCAL EL
JOIN
BI.LOCAL L ON EL.local_id = L.id
JOIN
BI.DIA D ON D.id = EL.dia_semana_reclamo_id
JOIN
BI.RANGO_HORARIO RH ON RH.id = EL.rango_horario_id
GROUP BY
EL.local_id,
L.nombre_local,
D.dia_de_semana,
RH.rango_horario_inicio,
RH.rango_horario_fin;
GO

CREATE VIEW BI.tiempo_resolucion_reclamos AS
SELECT
AVG(ER.tiempo_resolucion) as tiempo_resolucion_promedio,
TR.tipo_reclamo,
RE.rango_etario_inicio,
RE.rango_etario_fin
FROM
BI.ESTADISTICAS_RECLAMOS ER
JOIN
BI.TIPO_RECLAMO TR ON ER.tipo_reclamo_id = TR.id
JOIN
BI.RANGO_ETARIO RE ON ER.rango_etario_operador_id = RE.id
GROUP BY
TR.tipo_reclamo,
RE.rango_etario_inicio,
RE.rango_etario_fin
GO

CREATE VIEW BI.monto_mensual_cupones_reclamos AS
SELECT
SUM(ER.monto_mensual_cupones) as monto_mensual_cupones,
M.año,
M.mes
FROM
BI.ESTADISTICAS_RECLAMOS ER
JOIN
BI.MES M ON M.id = ER.mes_anio_id
GROUP BY
M.año,M.mes;
GO







