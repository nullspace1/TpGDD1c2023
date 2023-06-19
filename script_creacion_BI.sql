

IF EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'BI')
BEGIN
   DECLARE @sql NVARCHAR(MAX) = N'';


	SELECT @sql += N'
	ALTER TABLE [' + OBJECT_SCHEMA_NAME(fk.parent_object_id) + N'].[' + OBJECT_NAME(fk.parent_object_id) + N']
	DROP CONSTRAINT [' + fk.name + N'];'
	FROM sys.foreign_keys AS fk
	JOIN sys.tables AS t ON fk.parent_object_id = t.object_id
	WHERE SCHEMA_NAME(t.schema_id) = N'BI';

	SELECT @sql += N'
	DROP TABLE [' + SCHEMA_NAME(schema_id) + N'].[' + name + N'];'
	FROM sys.tables
	WHERE SCHEMA_NAME(schema_id) = N'BI';

	SET @sql += N'DROP SCHEMA [BI];';

	EXEC sp_executesql @sql;

	-- Drop procedure dia_y_franja_max_pedidos_localidad_categoria
DROP PROCEDURE  dia_y_franja_max_pedidos_localidad_categoria;


-- Drop procedure sp_obtener_monto_no_cobrado_por_pedidos_cancelados
DROP PROCEDURE  sp_obtener_monto_no_cobrado_por_pedidos_cancelados;


-- Drop procedure sp_obtener_desvio_promedio_tiempo_entrega
DROP PROCEDURE sp_obtener_desvio_promedio_tiempo_entrega;


-- Drop procedure sp_obtener_monto_total_cupones_utilizados
DROP PROCEDURE  sp_obtener_monto_total_cupones_utilizados;

-- Drop procedure sp_obtener_calificacion_mensual_local
DROP PROCEDURE  sp_obtener_calificacion_mensual_local;


-- Drop procedure sp_obtener_pedidos_envios_entregados_mensualmente
DROP PROCEDURE sp_obtener_pedidos_envios_entregados_mensualmente;


-- Drop procedure sp_obtener_promedio_mensual_valor_asegudaro
DROP PROCEDURE sp_obtener_promedio_mensual_valor_asegudaro;


-- Drop procedure sp_obtener_cantidad_reclamos_mensuales
DROP PROCEDURE sp_obtener_cantidad_reclamos_mensuales;


-- Drop procedure sp_obtener_tiempo_resolucion_reclamos
DROP PROCEDURE sp_obtener_tiempo_resolucion_reclamos;

-- Drop procedure sp_obtener_monto_mensual_cupones
DROP PROCEDURE sp_obtener_monto_mensual_cupones;


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

CREATE TABLE BI.PROVINCIA(
id int,
nombre NVARCHAR(255),
PRIMARY KEY (id)
);

CREATE TABLE BI.LOCALIDAD(
id int,
nombre NVARCHAR(255),
provincia_id INT NOT NULL,
PRIMARY KEY (id)
);

CREATE TABLE BI.TIPO_MEDIO_PAGO (
  id INT,
  tipo_medio_pago NVARCHAR(50),
  PRIMARY KEY (id)
);

CREATE TABLE BI.LOCAL (
  id INT,
  nombre_local NVARCHAR(255),
  descripcion_local NVARCHAR(255),
  localidad_id INT,
  categoria_local_id INT
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
	PRIMARY KEY(id)
)

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

CREATE TABLE BI.ESTADO_ENVIO_PEDIDO (
  id INT,
  estado_pedido NVARCHAR(50),
  PRIMARY KEY (id)
);

CREATE TABLE BI.ESTADO_ENVIO_MENSAJERIA (
  id INT,
  estado_envio NVARCHAR(50),
  PRIMARY KEY (id)
);

CREATE TABLE BI.ESTADO_RECLAMO (
  id INT,
  estado_reclamo NVARCHAR(50),
  PRIMARY KEY (id)
);

CREATE TABLE BI.TIPO_RECLAMO (
id INT,
tipo_reclamo NVARCHAR(50),
PRIMARY KEY (id)
)


CREATE TABLE BI.ESTADISTICAS_PEDIDOS (
    id INT IDENTITY(1,1),

    local_id INT,
	anio_mes_id INT,
    franja_horaria_id INT,
    dia_semana_id INT,
	estado_pedido_id INT,

    cantidad_pedidos INT,
    valor_total DECIMAL(18,2),
    
    PRIMARY KEY (id)
);

CREATE TABLE BI.ESTADISTICAS_ENVIOS_PEDIDOS(
    id INT IDENTITY(1,1),

    anio_mes_id INT,
    localidad_id INT,

	valor_total DECIMAL(18,2),
    PRIMARY KEY (id)
);

CREATE TABLE BI.ESTADISTICAS_ENVIOS_MENSAJERIA(
  id INT IDENTITY(1,1),
  
  tipo_paquete_id INT,
  anio_mes_id INT,

  valor_promedio DECIMAL(18,2),
  PRIMARY KEY (id)
);

CREATE TABLE BI.ESTADISTICAS_ENVIOS_TOTAL(
  id INT IDENTITY(1,1),
 
  tipo_movilidad_id INT,
  dia_semana_id INT,
  franja_horaria_id INT,
  rango_etario_id INT,
  localidad_id INT,
  
  cantidad_envios INT,
  desvio_tiempo DECIMAL(18,2),
  PRIMARY KEY (id)
);

CREATE TABLE BI.ESTADISTICAS_LOCAL(
  id INT IDENTITY(1,1),

  local_id INT,
  mes_anio_id INT,
  dia_semana_reclamo_id INT,
  rango_horario_id INT,

  cantidad_reclamos INT,
  calificacion_promedio DECIMAL(18,0),
  PRIMARY KEY (id)
);

CREATE TABLE BI.ESTADISTICAS_RECLAMOS(
  id INT IDENTITY(1,1),
 
  mes_anio_id INT,
  
  dia_semana_id INT,
  rango_horario_id INT,
  tipo_reclamo_id INT,
  rango_etario_operador_id INT,

  cantidad_reclamos INT,
  monto_mensual_cupones DECIMAL(18,2),
  tiempo_resolucion DECIMAL(18,2),
  PRIMARY KEY (id)
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


INSERT INTO BI.PROVINCIA(id,nombre)
SELECT
id_provincia,
nombre
FROM ESECUELE.PROVINCIA 


INSERT INTO BI.LOCALIDAD (id,nombre,provincia_id)
SELECT
id_localidad,
nombre,
provincia_id
FROM ESECUELE.LOCALIDAD 

INSERT INTO BI.TIPO_MEDIO_PAGO (id,tipo_medio_pago)
SELECT
id_medio_de_pago,
tipo
FROM 
ESECUELE.MEDIO_DE_PAGO;


INSERT INTO BI.LOCAL (id, nombre_local, descripcion_local, localidad_id,categoria_local_id)
SELECT 
id_local, 
nombre, 
descripcion, 
localidad_id,
categoria_local_id
FROM ESECUELE.LOCAL;

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
GO

INSERT INTO BI.ESTADO_ENVIO_PEDIDO (id,estado_pedido)
SELECT DISTINCT
EP.id_estado_pedido,
EP.estado
FROM
ESECUELE.ESTADO_PEDIDO EP
GO

INSERT INTO BI.ESTADO_ENVIO_MENSAJERIA (id,estado_envio)
SELECT DISTINCT
EE.id_estado_envio,
EE.estado
FROM
ESECUELE.ESTADO_ENVIO EE
GO


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
*
FROM ESECUELE.TIPO_RECLAMO


INSERT INTO BI.ESTADO_RECLAMO (id, estado_reclamo)
SELECT id_estado_reclamo, nombre
FROM ESECUELE.ESTADO_RECLAMO;
GO

----

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
    local_id,
	dbo.MES_ANIO_ID(ESECUELE.PEDIDO.fecha_pedido),
    dbo.FRANJA_HORARIA(ESECUELE.PEDIDO.fecha_pedido) AS franja_horaria_id,
    DATEPART(weekday, ESECUELE.PEDIDO.fecha_pedido) AS dia_semana_id,
    COUNT(*) AS cantidad_envios,
    SUM(total_pedido - ISNULL(total_cupones, 0)) AS valor_total,
	ESECUELE.PEDIDO.estado_pedido_id
FROM 
    ESECUELE.PEDIDO
GROUP BY
    local_id,
    dbo.FRANJA_HORARIA(ESECUELE.PEDIDO.fecha_pedido),
    DATEPART(weekday, ESECUELE.PEDIDO.fecha_pedido),
    estado_pedido_id,
	dbo.MES_ANIO_ID(ESECUELE.PEDIDO.fecha_pedido)
ORDER BY local_id



INSERT INTO BI.ESTADISTICAS_ENVIOS_PEDIDOS(valor_total, anio_mes_id, localidad_id)
SELECT
    SUM(P.total_pedido + E.tarifa_servicio + E.propina - ISNULL(P.total_cupones, 0)) AS valor_total,
    M.id,
	LI.id
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




DROP FUNCTION dbo.FRANJA_HORARIA
DROP FUNCTION dbo.RANGO_ETARIO
DROP FUNCTION dbo.MES_ANIO_ID
GO


/*
 Monto total no cobrado por cada local en función de los pedidos
cancelados según el día de la semana y la franja horaria (cuentan como
pedidos cancelados tanto los que cancela el usuario como el local).
*/

CREATE PROCEDURE dia_y_franja_max_pedidos_localidad_categoria
AS
BEGIN
    SELECT 
        BIM.año,
        BIM.mes,
        BIL.nombre AS localidad,
        BITCL.categoria_local,
        BIDS.dia_de_semana,
        BIRH.rango_horario_inicio,
        BIRH.rango_horario_fin,
        MAX(BIEP.cantidad_pedidos) AS maxima_cantidad_envios
    FROM 
        BI.ESTADISTICAS_PEDIDOS BIEP
    JOIN 
        BI.MES BIM ON BIEP.anio_mes_id = BIM.id
    JOIN
		BI.LOCAL BILOC ON BILOC.id = BIEP.local_id 
	JOIN
        BI.LOCALIDAD BIL ON BILOC.localidad_id = BIL.id
    JOIN 
        BI.CATEGORIA_LOCAL BITCL ON BILOC.categoria_local_id = BITCL.id
    JOIN 
        BI.DIA BIDS ON BIEP.dia_semana_id = BIDS.id
    JOIN 
        BI.RANGO_HORARIO BIRH ON BIEP.franja_horaria_id = BIRH.id
    GROUP BY 
        BIM.año,
        BIM.mes,
        BIL.nombre,
        BITCL.categoria_local,
        BIDS.dia_de_semana,
        BIRH.rango_horario_inicio,
        BIRH.rango_horario_fin;
END;
GO

/*
Valor promedio mensual que tienen los envíos de pedidos en cada
localidad.
*/

CREATE PROCEDURE sp_obtener_monto_no_cobrado_por_pedidos_cancelados
AS
BEGIN
    SELECT 
        BIL.nombre_local AS local,
        BIDS.dia_de_semana,
        BIRH.rango_horario_inicio,
        BIRH.rango_horario_fin,
        SUM(BIEP.valor_total) AS total_no_cobrado
    FROM 
        BI.ESTADISTICAS_PEDIDOS BIEP
    JOIN 
        BI.LOCAL BIL ON BIEP.local_id = BIL.id
    JOIN 
        BI.DIA BIDS ON BIEP.dia_semana_id = BIDS.id
    JOIN 
        BI.RANGO_HORARIO BIRH ON BIEP.franja_horaria_id = BIRH.id
    JOIN 
        BI.ESTADO_ENVIO_PEDIDO BIEP2 ON BIEP.estado_pedido_id = BIEP2.id
    WHERE 
        BIEP2.estado_pedido IN ('Estado Mensajeria Cancelado')
    GROUP BY 
        BIL.nombre_local,
        BIDS.dia_de_semana,
        BIRH.rango_horario_inicio,
        BIRH.rango_horario_fin;
END;
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

CREATE PROCEDURE sp_obtener_desvio_promedio_tiempo_entrega
AS
BEGIN

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
	RH.rango_horario_fin 

END
GO
/*
Monto total de los cupones utilizados por mes en función del rango etario
de los usuarios
*/

CREATE PROCEDURE sp_obtener_monto_total_cupones_utilizados
AS
BEGIN

	SELECT
	EC.monto_total_cupones as monto_total,
	RE.rango_etario_inicio as rango_etario_comienzo,
	RE.rango_etario_fin as rango_estario_fin
	FROM
	BI.ESTADISTICAS_CUPONES EC
	JOIN
	BI.RANGO_ETARIO RE ON RE.id = EC.rango_etario_usuario_id

END
GO

/*Promedio de calificación mensual por local.*/

CREATE PROCEDURE sp_obtener_calificacion_mensual_local
AS
BEGIN
	
	SELECT
	EL.local_id,
	AVG(EL.calificacion_promedio) as calificacion_promedio
	FROM
	BI.ESTADISTICAS_LOCAL EL
	GROUP BY
	EL.mes_anio_id,
	EL.local_id

END
GO

/*
Porcentaje de pedidos y mensajería entregados mensualmente según el
rango etario de los repartidores y la localidad.
Este indicador se debe tener en cuenta y sumar tanto los envíos de pedidos
como los de mensajería.
El porcentaje se calcula en función del total general de pedidos y envíos
mensuales entregados.
*/

CREATE PROCEDURE sp_obtener_pedidos_envios_entregados_mensualmente
AS
BEGIN
	
	DECLARE @total_envios DECIMAL(18,2)
	SET @total_envios = (SELECT SUM(EET2.cantidad_envios) FROM BI.ESTADISTICAS_ENVIOS_TOTAL EET2)

	SELECT
	SUM(EET.cantidad_envios) OVER (PARTITION BY EET.localidad_id, EET.rango_etario_id) / @total_envios as porcentage_envios,
	RE.rango_etario_inicio as rango_etario_repartidor_comienzo,
	RE.rango_etario_fin as rango_etario_repartidor_fin,
	L.nombre as localidad
	FROM
	BI.ESTADISTICAS_ENVIOS_TOTAL EET
	JOIN
	BI.RANGO_ETARIO RE ON RE.id = EET.rango_etario_id
	JOIN
	BI.LOCALIDAD L ON L.id = EET.localidad_id

END
GO


/*
Promedio mensual del valor asegurado (valor declarado por el usuario) de
los paquetes enviados a través del servicio de mensajería en función del
tipo de paquete.
*/

CREATE PROCEDURE sp_obtener_promedio_mensual_valor_asegudaro
AS
BEGIN

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
	BI.MES M ON M.id = EEM.anio_mes_id

END
GO


/*
Cantidad de reclamos mensuales recibidos por cada local en función del
día de la semana y rango horario.
*/

CREATE PROCEDURE sp_obtener_cantidad_reclamos_mensuales
AS
BEGIN

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
	RH.rango_horario_fin

END
GO



/*
Tiempo promedio de resolución de reclamos mensual según cada tipo de
reclamo y rango etario de los operadores.
El tiempo de resolución debe calcularse en minutos y representa la
diferencia entre la fecha/hora en que se realizó el reclamo y la fecha/hora
que se resolvió.
*/

CREATE PROCEDURE sp_obtener_tiempo_resolucion_reclamos
AS
BEGIN

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
	ORDER BY
	RE.rango_etario_inicio





END
GO

/* Monto mensual generado en cupones a partir de reclamos. */


CREATE PROCEDURE sp_obtener_monto_mensual_cupones
AS
BEGIN
	
	SELECT
	SUM(ER.monto_mensual_cupones),
	M.año,
	M.mes
	FROM
	BI.ESTADISTICAS_RECLAMOS ER
	JOIN
	BI.MES M ON M.id = ER.mes_anio_id
	GROUP BY
	M.año,M.mes

END


EXEC dia_y_franja_max_pedidos_localidad_categoria; -- no sabemos

	
EXEC sp_obtener_monto_no_cobrado_por_pedidos_cancelados; -- bien


EXEC sp_obtener_desvio_promedio_tiempo_entrega; -- bien


EXEC sp_obtener_monto_total_cupones_utilizados; -- bien


EXEC sp_obtener_calificacion_mensual_local; -- bien


EXEC sp_obtener_pedidos_envios_entregados_mensualmente; -- bien


EXEC sp_obtener_promedio_mensual_valor_asegudaro; -- bien



EXEC sp_obtener_cantidad_reclamos_mensuales; -- bien


EXEC sp_obtener_tiempo_resolucion_reclamos; -- bien


EXEC sp_obtener_monto_mensual_cupones;


-- Select from MES
SELECT * FROM BI.MES;

-- Select from DIA
SELECT * FROM BI.DIA;

-- Select from RANGO_HORARIO
SELECT * FROM BI.RANGO_HORARIO;

-- Select from RANGO_ETARIO
SELECT * FROM BI.RANGO_ETARIO;

-- Select from PROVINCIA
SELECT * FROM BI.PROVINCIA;

-- Select from LOCALIDAD
SELECT * FROM BI.LOCALIDAD;

-- Select from TIPO_MEDIO_PAGO
SELECT * FROM BI.TIPO_MEDIO_PAGO;

-- Select from LOCAL
SELECT * FROM BI.LOCAL;

-- Select from TIPO_LOCAL
SELECT * FROM BI.TIPO_LOCAL;

-- Select from CATEGORIA_LOCAL
SELECT * FROM BI.CATEGORIA_LOCAL;

-- Select from TIPO_MOVILIDAD
SELECT * FROM BI.TIPO_MOVILIDAD;

-- Select from TIPO_PAQUETE
SELECT * FROM BI.TIPO_PAQUETE;

-- Select from ESTADO_ENVIO_PEDIDO
SELECT * FROM BI.ESTADO_ENVIO_PEDIDO;

-- Select from ESTADO_ENVIO_MENSAJERIA
SELECT * FROM BI.ESTADO_ENVIO_MENSAJERIA;

-- Select from ESTADO_RECLAMO
SELECT * FROM BI.ESTADO_RECLAMO;

-- Select from TIPO_RECLAMO
SELECT * FROM BI.TIPO_RECLAMO;

-- Select from ESTADISTICAS_PEDIDOS
SELECT * FROM BI.ESTADISTICAS_PEDIDOS;

-- Select from ESTADISTICAS_ENVIOS_PEDIDOS
SELECT * FROM BI.ESTADISTICAS_ENVIOS_PEDIDOS;

-- Select from ESTADISTICAS_ENVIOS_MENSAJERIA
SELECT * FROM BI.ESTADISTICAS_ENVIOS_MENSAJERIA;

-- Select from ESTADISTICAS_ENVIOS_TOTAL
SELECT * FROM BI.ESTADISTICAS_ENVIOS_TOTAL;

-- Select from ESTADISTICAS_LOCAL
SELECT * FROM BI.ESTADISTICAS_LOCAL;

-- Select from ESTADISTICAS_RECLAMOS
SELECT * FROM BI.ESTADISTICAS_RECLAMOS;

-- Select from ESTADISTICAS_CUPONES
SELECT * FROM BI.ESTADISTICAS_CUPONES;
