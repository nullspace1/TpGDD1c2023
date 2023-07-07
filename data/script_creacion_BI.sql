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
CREATE TABLE BI.DIMENSION_MES (
  id INT IDENTITY(1,1),
  año INT,
  mes INT,
  PRIMARY KEY (id)
);

CREATE TABLE BI.DIMENSION_DIA (
  id INT IDENTITY(1,1),
  dia_de_semana NVARCHAR(50),
  PRIMARY KEY (id)
);

CREATE TABLE BI.DIMENSION_RANGO_HORARIO (
  id INT IDENTITY(1,1),
  rango_horario_inicio INT,
  rango_horario_fin INT,
  PRIMARY KEY (id)
);

CREATE TABLE BI.DIMENSION_RANGO_ETARIO (
  id INT IDENTITY(1,1),
  rango_etario_inicio INT,
  rango_etario_fin INT,
  PRIMARY KEY (id)
);

CREATE TABLE BI.DIMENSION_LOCALIDAD (
  id INT,
  nombre_localidad NVARCHAR(255),
  nombre_provincia NVARCHAR(255),
  PRIMARY KEY (id)
);


CREATE TABLE BI.DIMENSION_CATEGORIA_TIPO_LOCAL (
  id INT,
  categoria_local NVARCHAR(50),
  tipo_local NVARCHAR(50),
  PRIMARY KEY(id),
);

CREATE TABLE BI.DIMENSION_LOCAL (
  id INT,
  nombre_local NVARCHAR(255),
  PRIMARY KEY (id),
);

CREATE TABLE BI.DIMENSION_TIPO_MOVILIDAD (
  id INT,
  tipo_movilidad NVARCHAR(50),
  PRIMARY KEY (id)
);

CREATE TABLE BI.DIMENSION_TIPO_PAQUETE (
  id INT,
  tipo_paquete NVARCHAR(50),
  PRIMARY KEY (id)
);

CREATE TABLE BI.DIMENSION_TIPO_RECLAMO (
  id INT,
  tipo_reclamo NVARCHAR(50),
  PRIMARY KEY (id)
);

CREATE TABLE BI.DIMENSION_ESTADO_PEDIDO (
  id INT,
  estado_pedido NVARCHAR(50),
  PRIMARY KEY(id)
);


CREATE TABLE BI.HECHOS_PEDIDOS (
    id INT IDENTITY(1,1),

	local_id INT,
	tipo_categoria_local_id INT,
	localidad_id INT,
    anio_mes_id INT,
    franja_horaria_id INT,
    dia_semana_id INT,
	estado_pedido_id INT,


    cantidad_pedidos INT,
	valor_total DECIMAL(18,2),
	calificacion_promedio DECIMAL(18,0),
	cantidad_reclamos INT

    PRIMARY KEY (id),
    FOREIGN KEY (tipo_categoria_local_id) REFERENCES BI.DIMENSION_CATEGORIA_TIPO_LOCAL (id),
    FOREIGN KEY (anio_mes_id) REFERENCES BI.DIMENSION_MES (id),
    FOREIGN KEY (franja_horaria_id) REFERENCES BI.DIMENSION_RANGO_HORARIO (id),
    FOREIGN KEY (dia_semana_id) REFERENCES BI.DIMENSION_DIA (id),
	FOREIGN KEY (localidad_id) REFERENCES BI.DIMENSION_LOCALIDAD(id),
	FOREIGN KEY (estado_pedido_id) REFERENCES BI.DIMENSION_ESTADO_PEDIDO(id)
);


CREATE TABLE BI.HECHOS_ENVIOS_PEDIDOS (
    id INT IDENTITY(1,1),

    anio_mes_id INT,
    localidad_id INT,

    valor_total DECIMAL(18,2),
    PRIMARY KEY (id),
    FOREIGN KEY (anio_mes_id) REFERENCES BI.DIMENSION_MES (id),
    FOREIGN KEY (localidad_id) REFERENCES BI.DIMENSION_LOCALIDAD (id)
);

CREATE TABLE BI.HECHOS_ENVIOS_MENSAJERIA (
    id INT IDENTITY(1,1),

    tipo_paquete_id INT,
    anio_mes_id INT,

    valor_promedio DECIMAL(18,2),

    PRIMARY KEY (id),
    FOREIGN KEY (tipo_paquete_id) REFERENCES BI.DIMENSION_TIPO_PAQUETE (id),
    FOREIGN KEY (anio_mes_id) REFERENCES BI.DIMENSION_MES (id)
);

CREATE TABLE BI.HECHOS_ENVIOS_TOTAL (
    id INT IDENTITY(1,1),

    tipo_movilidad_id INT,
    dia_semana_id INT,
    franja_horaria_id INT,
    rango_etario_id INT,
    localidad_id INT,
	anio_mes_id INT,

    cantidad_envios INT,
    desvio_tiempo DECIMAL(18,2),

    PRIMARY KEY (id),
    FOREIGN KEY (tipo_movilidad_id) REFERENCES BI.DIMENSION_TIPO_MOVILIDAD (id),
    FOREIGN KEY (dia_semana_id) REFERENCES BI.DIMENSION_DIA (id),
    FOREIGN KEY (franja_horaria_id) REFERENCES BI.DIMENSION_RANGO_HORARIO (id),
    FOREIGN KEY (rango_etario_id) REFERENCES BI.DIMENSION_RANGO_ETARIO (id),
    FOREIGN KEY (localidad_id) REFERENCES BI.DIMENSION_LOCALIDAD (id),
	FOREIGN KEY (anio_mes_id) REFERENCES BI.DIMENSION_MES (id)
);

CREATE TABLE BI.HECHOS_RECLAMOS (
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
    FOREIGN KEY (mes_anio_id) REFERENCES BI.DIMENSION_MES (id),
    FOREIGN KEY (dia_semana_id) REFERENCES BI.DIMENSION_DIA (id),
    FOREIGN KEY (rango_horario_id) REFERENCES BI.DIMENSION_RANGO_HORARIO (id),
    FOREIGN KEY (tipo_reclamo_id) REFERENCES BI.DIMENSION_TIPO_RECLAMO (id),
    FOREIGN KEY (rango_etario_operador_id) REFERENCES BI.DIMENSION_RANGO_ETARIO (id)
);

CREATE TABLE BI.HECHOS_CUPONES (
    id INT IDENTITY(1,1),

	rango_etario_usuario_id INT,
	mes_anio_id INT,

    monto_total_cupones DECIMAL(18,2),

    PRIMARY KEY (id),
    FOREIGN KEY (rango_etario_usuario_id) REFERENCES BI.DIMENSION_RANGO_ETARIO (id),
	FOREIGN KEY (mes_anio_id) REFERENCES BI.DIMENSION_MES (id)
);



INSERT INTO BI.DIMENSION_MES (mes, año)
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


INSERT INTO BI.DIMENSION_DIA (dia_de_semana) VALUES
('LUNES'),
('MARTES'),
('MIERCOLES'),
('JUEVES'),
('VIERNES'),
('SABADO'),
('DOMINGO');


INSERT INTO BI.DIMENSION_RANGO_ETARIO (rango_etario_inicio, rango_etario_fin)
VALUES
(0, 24),
(25, 35),
(35, 55),
(56, 999);


INSERT INTO BI.DIMENSION_RANGO_HORARIO (rango_horario_inicio, rango_horario_fin)
VALUES
(8, 10),
(10, 12),
(12, 14),
(14, 16),
(16, 18),
(18, 20),
(20, 22),
(22,23),
(23, 24);


INSERT INTO BI.DIMENSION_CATEGORIA_TIPO_LOCAL (id,categoria_local,tipo_local)
SELECT DISTINCT
CL.id_categoria_local,
CL.categoria,
TL.tipo
FROM ESECUELE.LOCAL L
JOIN ESECUELE.TIPO_LOCAL TL ON L.tipo_local_id = TL.id_tipo_local
JOIN ESECUELE.CATEGORIA_LOCAL CL ON L.categoria_local_id = CL.id_categoria_local;


INSERT INTO BI.DIMENSION_ESTADO_PEDIDO (id,estado_pedido)
SELECT DISTINCT
EP.id_estado_pedido,
EP.estado
FROM
ESECUELE.ESTADO_PEDIDO EP


INSERT INTO BI.DIMENSION_TIPO_MOVILIDAD (id,tipo_movilidad)
SELECT DISTINCT
id_tipo_movilidad,
nombre
FROM
ESECUELE.TIPO_MOVILIDAD;


INSERT INTO BI.DIMENSION_TIPO_PAQUETE (id, tipo_paquete)
SELECT DISTINCT id_tipo_paquete, tipo
FROM ESECUELE.TIPO_PAQUETE;

INSERT INTO BI.DIMENSION_TIPO_RECLAMO (id,tipo_reclamo)
SELECT DISTINCT
TR.id_tipo_reclamo,
TR.tipo
FROM ESECUELE.TIPO_RECLAMO TR




INSERT INTO BI.DIMENSION_LOCALIDAD (id,nombre_localidad,nombre_provincia)
SELECT
id_localidad,
L.nombre,
P.nombre
FROM ESECUELE.LOCALIDAD L
JOIN ESECUELE.PROVINCIA P ON L.id_localidad = P.id_provincia


INSERT INTO BI.DIMENSION_LOCAL (id, nombre_local)
SELECT
id_local,
nombre
FROM ESECUELE.LOCAL LO
GO

CREATE FUNCTION FRANJA_HORARIA (@fecha DATETIME)
RETURNS INT
AS

BEGIN
RETURN
(SELECT
BI.DIMENSION_RANGO_HORARIO.id
FROM
BI.DIMENSION_RANGO_HORARIO
WHERE
 BI.DIMENSION_RANGO_HORARIO.rango_horario_inicio <= DATEPART(HOUR, @fecha)
            AND DATEPART(HOUR, @fecha) < BI.DIMENSION_RANGO_HORARIO.rango_horario_fin
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

    RETURN (SELECT TOP 1 RE.id FROM BI.DIMENSION_RANGO_ETARIO RE WHERE RE.rango_etario_inicio <= @anios AND RE.rango_etario_fin >= @anios)
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
    FROM BI.DIMENSION_MES
    WHERE año = YEAR(@fecha_hora_pedido) AND mes = MONTH(@fecha_hora_pedido);

    RETURN @mesId;
END;
GO

INSERT INTO BI.HECHOS_PEDIDOS(local_id,tipo_categoria_local_id,localidad_id,anio_mes_id, franja_horaria_id, dia_semana_id, cantidad_pedidos,estado_pedido_id, valor_total, calificacion_promedio,cantidad_reclamos)
SELECT
	DL.id,
    CL.id,
	LI.id,
	dbo.MES_ANIO_ID(P.fecha_pedido),
    dbo.FRANJA_HORARIA(P.fecha_pedido) AS franja_horaria_id,
    DATEPART(weekday, P.fecha_pedido) AS dia_semana_id,
    COUNT(*),
	DEP.id,
	SUM(P.total_pedido - P.total_cupones),
	AVG(P.calificacion),
	SUM(CASE WHEN R.id_reclamo IS NOT NULL THEN 1 ELSE 0 END)
FROM
    ESECUELE.PEDIDO P
	JOIN
	BI.DIMENSION_ESTADO_PEDIDO DEP ON DEP.id = P.estado_pedido_id
	JOIN
	ESECUELE.LOCAL L ON L.id_local = P.local_id
	JOIN
	BI.DIMENSION_LOCAL DL ON DL.id = L.id_local
	JOIN
	BI.DIMENSION_LOCALIDAD LI ON LI.id = L.localidad_id
	JOIN
	BI.DIMENSION_CATEGORIA_TIPO_LOCAL CL ON CL.id = L.categoria_local_id
	LEFT JOIN
	ESECUELE.RECLAMO R ON R.pedido_id = P.id_pedido
GROUP BY
    CL.id,
    dbo.FRANJA_HORARIA(P.fecha_pedido),
    DATEPART(weekday, P.fecha_pedido),
	dbo.MES_ANIO_ID(P.fecha_pedido),
	LI.id,
	DL.id,
	DEP.estado_pedido,
	DEP.id

INSERT INTO BI.HECHOS_ENVIOS_PEDIDOS(anio_mes_id,localidad_id,valor_total)
SELECT
    M.id,
	LI.id,
    SUM(P.total_pedido) AS valor_total
FROM
    ESECUELE.PEDIDO AS P
    JOIN ESECUELE.ENVIO AS E ON P.id_pedido = E.pedido_id
    JOIN BI.DIMENSION_MES AS M ON YEAR(P.fecha_pedido) = M.año AND MONTH(P.fecha_pedido) = M.mes
	JOIN ESECUELE.DIRECCION_USUARIO DU ON DU.id_direccion_usuario = E.direccion_usuario_id
	JOIN BI.DIMENSION_LOCALIDAD LI ON LI.id = DU.localidad_id
GROUP BY
M.id,
LI.id


INSERT INTO BI.HECHOS_ENVIOS_MENSAJERIA(valor_promedio, tipo_paquete_id, anio_mes_id)
SELECT
  AVG(total) AS valor_promedio,
  tipo_paquete_id,
  dbo.MES_ANIO_ID(fecha_hora_pedido)
FROM ESECUELE.ENVIO_MENSAJERIA
GROUP BY
tipo_paquete_id,
dbo.MES_ANIO_ID(fecha_hora_pedido)
GO


INSERT INTO BI.HECHOS_ENVIOS_TOTAL(tipo_movilidad_id,cantidad_envios, dia_semana_id, franja_horaria_id, desvio_tiempo, rango_etario_id, localidad_id,anio_mes_id)
SELECT
    id_tipo_movilidad,
	COUNT(*),
    DAY,
    FRANJA,
    AVG(desvio_tiempo),
    fecha_nac,
    LOCALIDAD,
	mes
FROM
    (
    SELECT
        TM.id_tipo_movilidad,
        DATEPART(weekday,E.fecha_pedido) AS DAY,
        dbo.FRANJA_HORARIA(E.fecha_pedido) AS FRANJA,
        (DATEDIFF(MINUTE, E.fecha_pedido, E.fecha_entrega) - E.tiempo_estimado_entrega) AS desvio_tiempo,
        dbo.RANGO_ETARIO(R.fecha_nac) as fecha_nac,
        L.id_localidad AS LOCALIDAD,
		dbo.MES_ANIO_ID(P.fecha_pedido) as mes
    FROM
        ESECUELE.ENVIO E
		JOIN ESECUELE.PEDIDO P ON P.id_pedido = E.pedido_id
        JOIN ESECUELE.REPARTIDOR R ON R.id_repartidor = E.repartidor_id
        JOIN ESECUELE.DIRECCION_USUARIO DU  ON DU.id_direccion_usuario = E.direccion_usuario_id
        JOIN ESECUELE.LOCALIDAD L ON L.id_localidad = DU.localidad_id
        JOIN ESECUELE.TIPO_MOVILIDAD TM ON TM.id_tipo_movilidad = R.tipo_movilidad_id
		JOIN BI.DIMENSION_LOCALIDAD LI ON LI.id = L.id_localidad
		JOIN ESECUELE.ESTADO_PEDIDO EP ON EP.id_estado_pedido = P.estado_pedido_id
	WHERE
		EP.estado = 'Estado Mensajeria Entregado'
    UNION ALL
    SELECT
        TM.id_tipo_movilidad,
        DATEPART(weekday,EM.fecha_hora_pedido) AS DAY,
        dbo.FRANJA_HORARIA(EM.fecha_hora_pedido) AS FRANJA,
        (DATEDIFF(MINUTE, EM.fecha_hora_pedido, EM.fecha_hora_entrega) - EM.tiempo_estimado) AS desvio_tiempo,
        dbo.RANGO_ETARIO(R.fecha_nac) as fecha_nac,
        L.id_localidad AS LOCALIDAD,
		dbo.MES_ANIO_ID(EM.fecha_hora_entrega) as mes
    FROM
        ESECUELE.ENVIO_MENSAJERIA EM
        JOIN ESECUELE.REPARTIDOR R ON R.id_repartidor = EM.repartidor_id
        JOIN ESECUELE.LOCALIDAD L ON L.id_localidad = EM.localidad_id
        JOIN ESECUELE.TIPO_MOVILIDAD TM ON TM.id_tipo_movilidad = R.tipo_movilidad_id
		JOIN BI.DIMENSION_LOCALIDAD LI ON LI.id = L.id_localidad
        JOIN ESECUELE.ESTADO_ENVIO_MENSAJERIA EEM ON EM.estado_id = EEM.id_estado_envio
    WHERE
        EEM.estado = 'Estado Mensajeria Entregado'
    ) as Combinado
GROUP BY
    id_tipo_movilidad,
    DAY,
    FRANJA,
    fecha_nac,
    LOCALIDAD,
	mes
	;




INSERT INTO BI.HECHOS_RECLAMOS(cantidad_reclamos,monto_mensual_cupones,mes_anio_id,tiempo_resolucion,dia_semana_id,rango_horario_id,tipo_reclamo_id,rango_etario_operador_id )
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

INSERT INTO BI.HECHOS_CUPONES (monto_total_cupones,rango_etario_usuario_id,mes_anio_id)
	SELECT
	SUM(C.descuento),
	dbo.RANGO_ETARIO(U.fecha_nac),
	dbo.MES_ANIO_ID(P.fecha_pedido)
	FROM
	ESECUELE.CUPON_APLICADO CU
	JOIN ESECUELE.PEDIDO P ON P.id_pedido = CU.pedido_id
	JOIN ESECUELE.CUPON C ON C.id_cupon = CU.cupon_id
	JOIN ESECUELE.CUPON_USUARIO CUS ON C.id_cupon = CUS.cupon_id
	JOIN ESECUELE.USUARIO U ON U.id_usuario = CUS.usuario_id
	GROUP BY
	dbo.RANGO_ETARIO(U.fecha_nac),
	dbo.MES_ANIO_ID(P.fecha_pedido)
GO

DROP FUNCTION dbo.FRANJA_HORARIA
DROP FUNCTION dbo.RANGO_ETARIO
DROP FUNCTION dbo.MES_ANIO_ID
GO

/*
Día de la semana y franja horaria con mayor cantidad de pedidos según la
localidad y categoría del local, para cada mes de cada año.
*/

CREATE VIEW BI.dia_franja_horaria_con_mayor_pedidos AS
SELECT
    D.dia_de_semana,
    RH.rango_horario_inicio,
    RH.rango_horario_fin,
    LI.nombre_localidad,
    LI.nombre_provincia,
    CTL.categoria_local,
    CTL.tipo_local,
    M.mes,
    M.año
FROM
    BI.HECHOS_PEDIDOS EP
    JOIN BI.DIMENSION_DIA D ON D.id = EP.dia_semana_id
    JOIN BI.DIMENSION_RANGO_HORARIO RH ON RH.id = EP.franja_horaria_id
    JOIN BI.DIMENSION_LOCALIDAD LI ON LI.id = EP.localidad_id
    JOIN BI.DIMENSION_CATEGORIA_TIPO_LOCAL CTL ON CTL.id = EP.tipo_categoria_local_id
    JOIN BI.DIMENSION_MES M ON M.id = EP.anio_mes_id
GROUP BY
    D.dia_de_semana,
    RH.rango_horario_inicio,
    RH.rango_horario_fin,
    LI.nombre_localidad,
    LI.nombre_provincia,
    CTL.categoria_local,
    CTL.tipo_local,
    M.mes,
    M.año,
    EP.localidad_id,
    EP.tipo_categoria_local_id,
    EP.anio_mes_id
	HAVING
    NOT EXISTS (
        SELECT 1
        FROM BI.HECHOS_PEDIDOS EP2
        WHERE
		EP2.localidad_id = EP.localidad_id
        AND EP2.tipo_categoria_local_id = EP.tipo_categoria_local_id
        AND EP2.anio_mes_id = EP.anio_mes_id
        GROUP BY
            EP2.anio_mes_id,
            EP2.localidad_id,
            EP2.tipo_categoria_local_id,
			EP2.franja_horaria_id,
			EP2.dia_semana_id
			HAVING
			SUM(ISNULL(EP2.cantidad_pedidos, 0)) > SUM(ISNULL(EP.cantidad_pedidos, 0))
    )
GO




/*
Monto total no cobrado por cada local en función de los pedidos
cancelados según el día de la semana y la franja horaria (cuentan como
pedidos cancelados tanto los que cancela el usuario como el local).
*/


CREATE VIEW BI.monto_total_no_cobrado AS
SELECT
L.nombre_local,
SUM(EL.valor_total) as valor_total_no_cobrado,
D.dia_de_semana as dia,
rango_horario_inicio,
rango_horario_fin
FROM
BI.HECHOS_PEDIDOS EL
JOIN
BI.DIMENSION_LOCAL L ON L.id = EL.local_id
JOIN
BI.DIMENSION_DIA D ON D.id = EL.dia_semana_id
JOIN
BI.DIMENSION_RANGO_HORARIO RH ON RH.id = EL.franja_horaria_id
WHERE
EL.estado_pedido_id = 2
GROUP BY
L.nombre_local,
D.dia_de_semana,
rango_horario_inicio,
rango_horario_fin
GO

/*
 Valor promedio mensual que tienen los envíos de pedidos en cada
localidad.
*/

CREATE VIEW BI.valor_promedio_mensual AS
SELECT
AVG(EEP.valor_total) as valor_promedio_mensual,
L.nombre_localidad as localidad,
M.mes,
M.año
FROM
BI.HECHOS_ENVIOS_PEDIDOS EEP
JOIN
BI.DIMENSION_LOCALIDAD L ON L.id = EEP.localidad_id
JOIN
BI.DIMENSION_MES M ON M.id = EEP.anio_mes_id
GROUP BY
L.nombre_localidad,
M.mes,
M.año
GO

/*
Desvío promedio en tiempo de entrega según el tipo de movilidad, el día
de la semana y la franja horaria.
El desvío debe calcularse en minutos y representa la diferencia entre la
fecha/hora en que se realizó el pedido y la fecha/hora que se entregó en
comparación con los minutos de tiempo estimados.
Este indicador debe tener en cuenta todos los envíos, es decir, sumar tanto
los envíos de pedidos como los de mensajería.
*/

CREATE VIEW BI.desvio_promedio_tiempo_entrega AS
SELECT
AVG(EET.desvio_tiempo) as desvio_tiempo,
D.dia_de_semana dia_semana,
TM.tipo_movilidad as tipo_movilidad,
RH.rango_horario_inicio as comienzo_rango_horario,
RH.rango_horario_fin as fin_rango_horario
FROM
BI.HECHOS_ENVIOS_TOTAL EET
JOIN
BI.DIMENSION_DIA D ON D.id = EET.dia_semana_id
JOIN
BI.DIMENSION_TIPO_MOVILIDAD TM ON TM.id = EET.tipo_movilidad_id
JOIN
BI.DIMENSION_RANGO_HORARIO RH ON RH.id = EET.franja_horaria_id
GROUP BY
EET.localidad_id,
D.dia_de_semana,
TM.tipo_movilidad,
RH.rango_horario_inicio ,
RH.rango_horario_fin;
GO

/*
Monto total de los cupones utilizados por mes en función del rango etario
de los usuarios
*/

CREATE VIEW BI.monto_total_cupones_utilizados AS
SELECT
EC.monto_total_cupones as monto_total,
RE.rango_etario_inicio as rango_etario_comienzo,
RE.rango_etario_fin as rango_estario_fin,
M.año,
M.mes
FROM
BI.HECHOS_CUPONES EC
JOIN
BI.DIMENSION_RANGO_ETARIO RE ON RE.id = EC.rango_etario_usuario_id
JOIN
BI.DIMENSION_MES M ON M.id = EC.mes_anio_id
GO

/* Promedio de calificación mensual por local. */

CREATE VIEW BI.calificacion_mensual_local AS
SELECT
L.nombre_local,
AVG(EL.calificacion_promedio) as calificacion_promedio
FROM
BI.HECHOS_PEDIDOS EL
JOIN
BI.DIMENSION_LOCAL L ON L.id = EL.local_id
GROUP BY
EL.anio_mes_id,
L.nombre_local
GO

/*
Porcentaje de pedidos y mensajería entregados mensualmente según el
rango etario de los repartidores y la localidad.
Este indicador se debe tener en cuenta y sumar tanto los envíos de pedidos
como los de mensajería.
El porcentaje se calcula en función del total general de pedidos y envíos
mensuales entregados.
*/


CREATE VIEW BI.pedidos_envios_entregados_mensualmente AS
SELECT
CAST(SUM(EET.cantidad_envios) AS DECIMAL(18,2)) / CAST((SELECT SUM(EET2.cantidad_envios) FROM BI.HECHOS_ENVIOS_TOTAL EET2) AS DECIMAL(18,2)) * 100 as porcentage_envios,
RE.rango_etario_inicio as rango_etario_repartidor_comienzo,
RE.rango_etario_fin as rango_etario_repartidor_fin,
L.nombre_localidad as localidad,
M.mes,
M.año
FROM
BI.HECHOS_ENVIOS_TOTAL EET
JOIN
BI.DIMENSION_RANGO_ETARIO RE ON RE.id = EET.rango_etario_id
JOIN
BI.DIMENSION_LOCALIDAD L ON L.id = EET.localidad_id
JOIN
BI.DIMENSION_MES M ON M.id = EET.anio_mes_id
GROUP BY
RE.rango_etario_inicio,
RE.rango_etario_fin,
L.nombre_localidad,
M.mes,
M.año,
EET.localidad_id,
EET.rango_etario_id
GO

/*
Promedio mensual del valor asegurado (valor declarado por el usuario) de
los paquetes enviados a través del servicio de mensajería en función del
tipo de paquete.
*/

CREATE VIEW BI.promedio_mensual_valor_asegurado AS
SELECT
valor_promedio as valor_promedio,
TP.tipo_paquete as tipo_paquete,
M.año as anio,
M.mes as mes
FROM
BI.HECHOS_ENVIOS_MENSAJERIA EEM
JOIN
BI.DIMENSION_TIPO_PAQUETE TP ON TP.id = EEM.tipo_paquete_id
JOIN
BI.DIMENSION_MES M ON M.id = EEM.anio_mes_id;
GO

/*
Cantidad de reclamos mensuales recibidos por cada local en función del
día de la semana y rango horario
*/

CREATE VIEW BI.cantidad_reclamos_mensuales AS
SELECT
L.nombre_local,
D.dia_de_semana,
RH.rango_horario_inicio,
RH.rango_horario_fin,
SUM(EL.cantidad_reclamos) as cant_reclamos
FROM
BI.HECHOS_PEDIDOS EL
JOIN
BI.DIMENSION_LOCAL L ON EL.local_id = L.id
JOIN
BI.DIMENSION_DIA D ON D.id = EL.dia_semana_id
JOIN
BI.DIMENSION_RANGO_HORARIO RH ON RH.id = EL.franja_horaria_id
GROUP BY
EL.local_id,
L.nombre_local,
D.dia_de_semana,
RH.rango_horario_inicio,
RH.rango_horario_fin;
GO

/*
Tiempo promedio de resolución de reclamos mensual según cada tipo de
reclamo y rango etario de los operadores.
El tiempo de resolución debe calcularse en minutos y representa la
diferencia entre la fecha/hora en que se realizó el reclamo y la fecha/hora
que se resolvió
*/

CREATE VIEW BI.tiempo_resolucion_reclamos AS
SELECT
AVG(ER.tiempo_resolucion) as tiempo_resolucion_promedio,
TR.tipo_reclamo,
RE.rango_etario_inicio,
RE.rango_etario_fin,
M.año,
M.mes
FROM
BI.HECHOS_RECLAMOS ER
JOIN
BI.DIMENSION_TIPO_RECLAMO TR ON ER.tipo_reclamo_id = TR.id
JOIN
BI.DIMENSION_RANGO_ETARIO RE ON ER.rango_etario_operador_id = RE.id
JOIN
BI.DIMENSION_MES M ON M.id = ER.mes_anio_id
GROUP BY
TR.tipo_reclamo,
RE.rango_etario_inicio,
RE.rango_etario_fin,
M.año,
M.mes
GO

/*Monto mensual generado en cupones a partir de reclamos.*/

CREATE VIEW BI.monto_mensual_cupones_reclamos AS
SELECT
SUM(ER.monto_mensual_cupones) as monto_mensual_cupones,
M.año,
M.mes
FROM
BI.HECHOS_RECLAMOS ER
JOIN
BI.DIMENSION_MES M ON M.id = ER.mes_anio_id
GROUP BY
M.año,M.mes
GO
