USE [GD1C2023]


IF EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'ESECUELE')
BEGIN
   DECLARE @sql NVARCHAR(MAX) = N'';


	SELECT @sql += N'
	ALTER TABLE [' + OBJECT_SCHEMA_NAME(fk.parent_object_id) + N'].[' + OBJECT_NAME(fk.parent_object_id) + N']
	DROP CONSTRAINT [' + fk.name + N'];'
	FROM sys.foreign_keys AS fk
	JOIN sys.tables AS t ON fk.parent_object_id = t.object_id
	WHERE SCHEMA_NAME(t.schema_id) = N'ESECUELE';

	SELECT @sql += N'
	DROP TABLE [' + SCHEMA_NAME(schema_id) + N'].[' + name + N'];'
	FROM sys.tables
	WHERE SCHEMA_NAME(schema_id) = N'ESECUELE';

	SET @sql += N'DROP SCHEMA [ESECUELE];';

	EXEC sp_executesql @sql;
END
GO


CREATE SCHEMA [ESECUELE]
GO

BEGIN TRANSACTION

CREATE TABLE ESECUELE.PROVINCIA(
id_provincia int IDENTITY(1,1) NOT NULL,
nombre NVARCHAR(255),
PRIMARY KEY (id_provincia)
);

CREATE TABLE ESECUELE.LOCALIDAD(
id_localidad INT IDENTITY(1,1) NOT NULL ,
nombre NVARCHAR(255),
provincia_id INT NOT NULL,

PRIMARY KEY (id_localidad),
FOREIGN KEY (provincia_id) REFERENCES ESECUELE.PROVINCIA (id_provincia)
);

CREATE TABLE ESECUELE.USUARIO(
id_usuario INT IDENTITY(1,1) NOT NULL ,
nombre NVARCHAR(255),
apellido NVARCHAR(255),
dni DECIMAL(18,0),
fecha_nac DATE,
fecha_registro DATETIME2(3),
telefono DECIMAL(18,0),
mail NVARCHAR(255),

PRIMARY KEY (id_usuario)
);


CREATE TABLE ESECUELE.DIRECCION_USUARIO(
id_direccion_usuario INT IDENTITY(1,1) NOT NULL ,
localidad_id INT NOT NULL,
usuario_id INT NOT NULL,
direccion NVARCHAR(255)

PRIMARY KEY (id_direccion_usuario),
FOREIGN KEY (localidad_id) REFERENCES ESECUELE.LOCALIDAD (id_localidad),
FOREIGN KEY (usuario_id) REFERENCES ESECUELE.USUARIO (id_usuario)
);


CREATE TABLE ESECUELE.ESTADO_RECLAMO(
id_estado_reclamo INT IDENTITY(1,1) NOT NULL ,
nombre NVARCHAR(50),

PRIMARY KEY(id_estado_reclamo)
);

CREATE TABLE ESECUELE.OPERADOR (
id_operador INT IDENTITY(1,1) NOT NULL ,
nombre NVARCHAR(255),
apellido NVARCHAR(255),
DNI DECIMAL(18,0),
telefono DECIMAL(18,0),
direccion NVARCHAR(255),
mail NVARCHAR(255),
fecha_nacimiento DATE,

PRIMARY KEY(id_operador)
);

CREATE TABLE ESECUELE.TIPO_CUPON(
id_tipo_cupon INT IDENTITY(1,1) NOT NULL ,
tipo NVARCHAR(50),
PRIMARY KEY(id_tipo_cupon)
);

CREATE TABLE ESECUELE.CUPON(
id_cupon INT  NOT NULL,
usuario_id INT NOT NULL,
fecha_alta DATE,
fecha_vencimiento DATE,
tipo_cupon_id INT NOT NULL,
descuento DECIMAL(18,2),

PRIMARY KEY (id_cupon),
FOREIGN KEY (usuario_id) REFERENCES ESECUELE.USUARIO (id_usuario),
FOREIGN KEY (tipo_cupon_id) REFERENCES ESECUELE.TIPO_CUPON (id_tipo_cupon)
);

CREATE TABLE ESECUELE.TIPO_MOVILIDAD(
id_tipo_movilidad INT IDENTITY(1,1) NOT NULL ,
nombre NVARCHAR(50),
PRIMARY KEY (id_tipo_movilidad)
);

CREATE TABLE ESECUELE.REPARTIDOR(
id_repartidor int IDENTITY(1,1) NOT NULL,
nombre NVARCHAR(255),
apellido NVARCHAR(255),
dni DECIMAL(18,0),
telefono DECIMAL(18,0),
direccion NVARCHAR(255),
email NVARCHAR(255),
fecha_nac DATE,
tipo_movilidad_id int,
localidad_id int

PRIMARY KEY (id_repartidor),
FOREIGN KEY (tipo_movilidad_id) REFERENCES ESECUELE.tipo_movilidad(id_tipo_movilidad),
FOREIGN KEY (localidad_id) REFERENCES ESECUELE.LOCALIDAD(id_localidad)
);

CREATE TABLE ESECUELE.TIPO_LOCAL (
id_tipo_local INT IDENTITY(1,1) NOT NULL ,
tipo NVARCHAR(50),

PRIMARY KEY(id_tipo_local)
);

CREATE TABLE ESECUELE.CATEGORIA_LOCAL(
id_categoria_local INT IDENTITY(1,1) NOT NULL ,
categoria NVARCHAR(50),
tipo_local_id INT

PRIMARY KEY(id_categoria_local)
FOREIGN KEY (tipo_local_id) REFERENCES ESECUELE.TIPO_LOCAL (id_tipo_local)
);



CREATE TABLE ESECUELE.LOCAL(
id_local INT IDENTITY(1,1) NOT NULL ,
categoria_local_id INT,
tipo_local_id INT,
nombre NVARCHAR(255),
descripcion NVARCHAR(255),
direccion NVARCHAR(255),
localidad_id INT,

FOREIGN KEY (tipo_local_id) REFERENCES ESECUELE.TIPO_LOCAL(id_tipo_local),
FOREIGN KEY(categoria_local_id) REFERENCES ESECUELE.CATEGORIA_LOCAL(id_categoria_local),
FOREIGN KEY (localidad_id) REFERENCES ESECUELE.LOCALIDAD(id_localidad),
PRIMARY KEY (id_local)
);

CREATE TABLE ESECUELE.HORARIOS_LOCAL (
id_horario_local INT IDENTITY(1,1) NOT NULL,
local_id INT,
horario_hora_apertura DECIMAL(18,0),
horario_hora_cierre  DECIMAL(18,0),
horario_hora_dia NVARCHAR(50),

PRIMARY KEY(id_horario_local),
FOREIGN KEY(local_id) REFERENCES ESECUELE.LOCAL(id_local)
)



CREATE TABLE ESECUELE.MEDIO_DE_PAGO(
id_medio_de_pago INT IDENTITY(1,1) NOT NULL ,
tipo NVARCHAR(50),
nro_tarjeta NVARCHAR(50),
usuario_id int,
marca_tarjeta NVARCHAR(100),

PRIMARY KEY(id_medio_de_pago),
FOREIGN KEY (usuario_id) REFERENCES ESECUELE.usuario(id_usuario)
);

CREATE TABLE ESECUELE.ESTADO_PEDIDO(
id_estado_pedido INT IDENTITY(1,1) NOT NULL ,
estado NVARCHAR(50),

PRIMARY KEY(id_estado_pedido)
);


CREATE TABLE ESECUELE.PEDIDO(
id_pedido INT  NOT NULL ,
usuario_id int,
local_id int,
medio_de_pago_id int,
observaciones NVARCHAR(255),
fecha_entrega DATETIME2(3),
tiempo_estimado_entrega decimal(18,0),
calificacion NVARCHAR(50),
total_pedido DECIMAL(18,2),
total_cupones DECIMAL(18,2),
estado_pedido_id INT,


PRIMARY KEY (id_pedido),
FOREIGN KEY (local_id) REFERENCES ESECUELE.local(id_local),
FOREIGN KEY (medio_de_pago_id) REFERENCES ESECUELE.medio_de_pago(id_medio_de_pago),
FOREIGN KEY (usuario_id) REFERENCES ESECUELE.usuario(id_usuario),
FOREIGN KEY (estado_pedido_id) REFERENCES ESECUELE.ESTADO_PEDIDO (id_estado_pedido)
);

CREATE TABLE ESECUELE.ENVIO(
id_envio INT IDENTITY(1,1) NOT NULL ,
pedido_id INT,
fecha_pedido DATETIME2,
direccion_usuario_id int,
tarifa_servicio int,
propina DECIMAL(18,2),
repartidor_id int,
precio_envio DECIMAL(18,2),

PRIMARY KEY (id_envio),
FOREIGN KEY (repartidor_id) REFERENCES ESECUELE.repartidor(id_repartidor),
FOREIGN KEY (pedido_id) REFERENCES ESECUELE.pedido(id_pedido),
FOREIGN KEY(direccion_usuario_id) REFERENCES ESECUELE.DIRECCION_USUARIO(id_direccion_usuario)
);


CREATE TABLE ESECUELE.CUPON_APLICADO(
cupon_id INT NOT NULL ,
pedido_id INT NOT NULL ,

PRIMARY KEY (cupon_id,pedido_id),
FOREIGN KEY (cupon_id) REFERENCES ESECUELE.cupon(id_cupon),
FOREIGN KEY (pedido_id) REFERENCES ESECUELE.pedido(id_pedido)
);


CREATE TABLE ESECUELE.PRODUCTO(
id_producto INT IDENTITY(1,1) NOT NULL ,
local_id INT,
codigo INT,
nombre NVARCHAR(255),
descripcion NVARCHAR(255),
precio_unitaro DECIMAL(18,2),

FOREIGN KEY (local_id) REFERENCES ESECUELE.LOCAL(id_local),
PRIMARY KEY (id_producto)
);

CREATE TABLE ESECUELE.PRODUCTO_PEDIDO(
id_producto INT  NOT NULL ,
nro_pedido INT  NOT NULL ,
cantidad INT,
total_productos DECIMAL(18,2),
precio_al_comprar DECIMAL(18,2),

FOREIGN KEY (id_producto) REFERENCES ESECUELE.PRODUCTO(id_producto),
FOREIGN KEY (nro_pedido) REFERENCES ESECUELE.PEDIDO (id_pedido),
PRIMARY KEY (id_producto, nro_pedido)
);

CREATE TABLE ESECUELE.TIPO_PAQUETE(
id_tipo_paquete INT IDENTITY(1,1) NOT NULL ,
tipo NVARCHAR(50),
ancho decimal(18,2),
alto decimal(18,2),
largo decimal(18,2),
peso decimal(18,2),
precio decimal(18,2),

PRIMARY KEY(id_tipo_paquete)
);

CREATE TABLE ESECUELE.ESTADO_ENVIO (
id_estado_envio INT IDENTITY(1,1) NOT NULL,
estado nvarchar(50),

PRIMARY KEY (id_estado_envio)
)

CREATE TABLE ESECUELE.ENVIO_MENSAJERIA (
id_envio INT IDENTITY(1,1) NOT NULL ,
usuario_id INT,
dir_origen NVARCHAR(255),
dir_destino NVARCHAR(255),
distancia_km DECIMAL(18,2),
localidad_id INT,
tipo_paquete_id INT,
valor_asegurado DECIMAL(18,2),
observaciones NVARCHAR(255),
precio_envio DECIMAL(18,2),
precio_seguro DECIMAL(18,2),
repartidor_id INT,
propina DECIMAL(18,2),
medio_de_pago_id INT,
fecha_hora_entrega DATETIME2(3),
fecha_hora_pedido DATETIME2(3),
calificacion DECIMAL(18,0),
total DECIMAL(18,2),
estado_id INT,
tiempo_estimado DECIMAL(18,2),
PRIMARY KEY(id_envio),
FOREIGN KEY(usuario_id) REFERENCES ESECUELE.USUARIO (id_usuario),
FOREIGN KEY(localidad_id) REFERENCES ESECUELE.LOCALIDAD (id_localidad),
FOREIGN KEY(tipo_paquete_id) REFERENCES ESECUELE.TIPO_PAQUETE (id_tipo_paquete),
FOREIGN KEY(repartidor_id) REFERENCES ESECUELE.REPARTIDOR (id_repartidor),
FOREIGN KEY(medio_de_pago_id) REFERENCES ESECUELE.MEDIO_DE_PAGO (id_medio_de_pago),
FOREIGN KEY(estado_id) REFERENCES ESECUELE.ESTADO_ENVIO (id_estado_envio)
);

CREATE TABLE ESECUELE.RECLAMO(
id_reclamo INT NOT NULL ,
usuario_id INT,
pedido_id INT,
tipo NVARCHAR(255),
descr NVARCHAR(255),
fecha_hora DATETIME2(3),
operador_id INT,
estado_reclamo_id INT,
solucion NVARCHAR(255),
fecha_hora_solucion DATE,
calificacion INT,

PRIMARY KEY(id_reclamo),
FOREIGN KEY(usuario_id) REFERENCES ESECUELE.USUARIO (id_usuario),
FOREIGN KEY(pedido_id) REFERENCES ESECUELE.PEDIDO (id_pedido),
FOREIGN KEY(operador_id) REFERENCES ESECUELE.OPERADOR (id_operador),
FOREIGN KEY(estado_reclamo_id) REFERENCES ESECUELE.ESTADO_RECLAMO (id_estado_reclamo)
);

CREATE TABLE ESECUELE.CUPON_RECLAMO(
cupon_id INT  NOT NULL ,
reclamo_id INT  NOT NULL ,

PRIMARY KEY(cupon_id,reclamo_id),
FOREIGN KEY (cupon_id) REFERENCES ESECUELE.CUPON (id_cupon),
FOREIGN KEY (reclamo_id) REFERENCES ESECUELE.RECLAMO (id_reclamo)
);

GO

COMMIT



-- Tabla temporal de Localidades y Provincias
SELECT
Union_Tablas.PROVINCIA,
Union_Tablas.LOCALIDAD
INTO
##LOCALIDAD_PROVINCIA
FROM
(
		(
		SELECT DISTINCT
		LOCAL_LOCALIDAD as LOCALIDAD,
		LOCAL_PROVINCIA as PROVINCIA
		FROM
		gd_esquema.Maestra
		)
	UNION
		(
		SELECT DISTINCT
		ENVIO_MENSAJERIA_LOCALIDAD as LOCALIDAD,
		ENVIO_MENSAJERIA_PROVINCIA as PROVINCIA
		FROM
		gd_esquema.Maestra
		)
	UNION
		(
		SELECT
		DIRECCION_USUARIO_LOCALIDAD as LOCALIDAD,
		DIRECCION_USUARIO_PROVINCIA as PROVINCIA
		FROM
		gd_esquema.Maestra
		)
	) as Union_Tablas

GO


CREATE PROCEDURE CREAR_LOCALIDADES
AS
BEGIN

	-- Creamos las Provincias --
	INSERT INTO ESECUELE.PROVINCIA (nombre)
		SELECT DISTINCT
		##LOCALIDAD_PROVINCIA.PROVINCIA
		FROM
		##LOCALIDAD_PROVINCIA

	-- Creamos las Localidades --
	INSERT INTO ESECUELE.LOCALIDAD (nombre,provincia_id)
		SELECT
		##LOCALIDAD_PROVINCIA.LOCALIDAD,
		P.id_provincia
		FROM
		##LOCALIDAD_PROVINCIA
		JOIN ESECUELE.PROVINCIA P ON ##LOCALIDAD_PROVINCIA.PROVINCIA = nombre


END
GO



CREATE PROCEDURE CREAR_USUARIOS
AS
BEGIN

	-- Condicion de PK para usuarios : DNI + NOMBRE + APELLIDO

	-- Insertamos los usuarios
	INSERT INTO ESECUELE.USUARIO (nombre,apellido,dni,fecha_nac,fecha_registro,telefono,mail)
		SELECT DISTINCT
		M.USUARIO_NOMBRE,
		M.USUARIO_APELLIDO,
		M.USUARIO_DNI,
		M.USUARIO_FECHA_NAC,
		M.USUARIO_FECHA_REGISTRO,
		M.USUARIO_TELEFONO,
		M.USUARIO_MAIL
		FROM
		gd_esquema.Maestra M


	-- Agregamos las direcciones del usuario --
	INSERT INTO ESECUELE.DIRECCION_USUARIO (localidad_id,usuario_id,direccion)
		SELECT DISTINCT
		L.id_localidad,
		U.id_usuario,
		M.DIRECCION_USUARIO_DIRECCION
		FROM
		gd_esquema.Maestra M
		JOIN
		ESECUELE.USUARIO U ON U.dni=M.USUARIO_DNI AND U.nombre=M.USUARIO_NOMBRE AND U.apellido = USUARIO_APELLIDO
		JOIN
		ESECUELE.PROVINCIA P ON M.DIRECCION_USUARIO_PROVINCIA = P.nombre
		JOIN
		ESECUELE.LOCALIDAD L ON M.DIRECCION_USUARIO_LOCALIDAD = L.nombre
		WHERE
		L.provincia_id = P.id_provincia



	-- Agregamos los medios de pago del usuario --
	INSERT INTO ESECUELE.MEDIO_DE_PAGO (tipo,nro_tarjeta,usuario_id,marca_tarjeta)
		SELECT DISTINCT
		M.MEDIO_PAGO_TIPO,
		M.MEDIO_PAGO_NRO_TARJETA,
		U.id_usuario,
		M.MARCA_TARJETA
		FROM
		gd_esquema.Maestra M
		JOIN ESECUELE.USUARIO U ON U.dni=M.USUARIO_DNI AND U.nombre=M.USUARIO_NOMBRE AND U.apellido = USUARIO_APELLIDO


END
GO


CREATE PROCEDURE CREAR_LOCALES
AS
BEGIN

	-- CONDICION DE PK para Locales: Nombre + Description + Localidad

	-- Insertamos los tipos de locales --
	INSERT INTO ESECUELE.TIPO_LOCAL (tipo)
		SELECT DISTINCT
		M.LOCAL_TIPO
		FROM
		gd_esquema.Maestra M


	-- Insertamos los locales propios --
	INSERT INTO ESECUELE.LOCAL (categoria_local_id,tipo_local_id,nombre,descripcion,direccion,localidad_id)
		SELECT DISTINCT
		NULL, -- Son las Categorias
		TL.id_tipo_local,
		M.LOCAL_NOMBRE,
		M.LOCAL_DESCRIPCION,
		M.LOCAL_DIRECCION,
		L.id_localidad
		FROM
		gd_esquema.Maestra M
		JOIN ESECUELE.TIPO_LOCAL TL ON M.LOCAL_TIPO = TL.tipo
		JOIN ESECUELE.LOCALIDAD L ON L.nombre  =  M.LOCAL_LOCALIDAD
		JOIN ESECUELE.PROVINCIA P ON P.nombre = M.LOCAL_PROVINCIA
		WHERE L.provincia_id = P.id_provincia

	INSERT INTO ESECUELE.HORARIOS_LOCAL (local_id,horario_hora_apertura,horario_hora_cierre,horario_hora_dia)
		SELECT DISTINCT
		L.id_local,
		M.HORARIO_LOCAL_HORA_APERTURA,
		M.HORARIO_LOCAL_HORA_CIERRE,
		M.HORARIO_LOCAL_DIA
		FROM
		gd_esquema.Maestra M
		JOIN ESECUELE.LOCAL L ON M.LOCAL_NOMBRE + M.LOCAL_DIRECCION  = L.nombre + L.direccion
		JOIN ESECUELE.LOCALIDAD LO ON LO.nombre = M.LOCAL_LOCALIDAD
		WHERE
		LO.id_localidad = L.localidad_id


	-- Insertamos los productos de cada local --

	INSERT INTO ESECUELE.PRODUCTO (local_id,codigo,nombre,descripcion,precio_unitaro)
		SELECT DISTINCT
		L.id_local,
		M.PRODUCTO_LOCAL_CODIGO,
		M.PRODUCTO_LOCAL_NOMBRE,
		M.PRODUCTO_LOCAL_DESCRIPCION,
		M.PRODUCTO_LOCAL_PRECIO
		FROM
		gd_esquema.Maestra M
		JOIN ESECUELE.LOCAL L ON L.nombre + L.descripcion = M.LOCAL_NOMBRE + M.LOCAL_DESCRIPCION
		JOIN ESECUELE.LOCALIDAD LO ON LO.nombre = M.LOCAL_LOCALIDAD
		WHERE
		LO.id_localidad = L.localidad_id


END
GO


CREATE PROCEDURE CREAR_REPARTIDORES
AS
BEGIN

	-- Creamos los tipos de movilidad de los repartidores --
	INSERT INTO ESECUELE.TIPO_MOVILIDAD (nombre)
		SELECT DISTINCT
		M.REPARTIDOR_TIPO_MOVILIDAD
		FROM
		gd_esquema.Maestra M
		GROUP BY
		M.REPARTIDOR_TIPO_MOVILIDAD

	-- Creamos los repartidores --
	INSERT INTO ESECUELE.REPARTIDOR (nombre,apellido,dni,telefono,direccion,fecha_nac,tipo_movilidad_id,localidad_id,email)
		SELECT DISTINCT
		M.REPARTIDOR_NOMBRE,
		M.REPARTIDOR_APELLIDO,
		M.REPARTIDOR_DNI,
		M.REPARTIDOR_TELEFONO,
		M.REPARTIDOR_DIRECION,
		M.REPARTIDOR_FECHA_NAC,
		TM.id_tipo_movilidad,
		NULL, -- Localidad activa es desconocida
		M.REPARTIDOR_EMAIL
		FROM
		gd_esquema.Maestra M
		JOIN ESECUELE.TIPO_MOVILIDAD TM ON M.REPARTIDOR_TIPO_MOVILIDAD = TM.nombre

END
GO

CREATE PROCEDURE CREAR_ENVIO_MENSAJERIA
AS
BEGIN

	-- Creamos los estados de envio --
	INSERT INTO ESECUELE.ESTADO_ENVIO (estado)
		SELECT DISTINCT
		M.ENVIO_MENSAJERIA_ESTADO
		FROM
		gd_esquema.Maestra M

	-- Creamos los tipos de paquete --
	INSERT INTO ESECUELE.TIPO_PAQUETE (tipo,ancho,alto,largo,peso,precio)
		SELECT DISTINCT
		M.PAQUETE_TIPO,
		M.PAQUETE_ANCHO_MAX,
		M.PAQUETE_ALTO_MAX,
		M.PAQUETE_LARGO_MAX,
		M.PAQUETE_PESO_MAX,
		M.PAQUETE_TIPO_PRECIO
		FROM
		gd_esquema.Maestra M



	-- Creamos los repartidores --
	INSERT INTO ESECUELE.ENVIO_MENSAJERIA (usuario_id,dir_origen,dir_destino,distancia_km,localidad_id,tipo_paquete_id,valor_asegurado,
											observaciones,precio_envio,precio_seguro,repartidor_id,propina,medio_de_pago_id,
											fecha_hora_entrega,fecha_hora_pedido,calificacion,total,estado_id,tiempo_estimado)
		SELECT DISTINCT
		U.id_usuario,
		M.ENVIO_MENSAJERIA_DIR_ORIG,
		M.ENVIO_MENSAJERIA_DIR_DEST,
		M.ENVIO_MENSAJERIA_KM,
		L.id_localidad,
		T.id_tipo_paquete,
		M.ENVIO_MENSAJERIA_VALOR_ASEGURADO,
		M.ENVIO_MENSAJERIA_OBSERV,
		M.ENVIO_MENSAJERIA_PRECIO_ENVIO,
		M.ENVIO_MENSAJERIA_PRECIO_SEGURO,
		R.id_repartidor,
		M.ENVIO_MENSAJERIA_PROPINA,
		MP.id_medio_de_pago,
		M.ENVIO_MENSAJERIA_FECHA_ENTREGA,
		M.ENVIO_MENSAJERIA_FECHA,
		M.ENVIO_MENSAJERIA_CALIFICACION,
		M.ENVIO_MENSAJERIA_TOTAL,
		E.id_estado_envio,
		M.ENVIO_MENSAJERIA_TIEMPO_ESTIMADO
		FROM
		gd_esquema.Maestra M
		JOIN ESECUELE.USUARIO U ON U.dni=M.USUARIO_DNI AND U.nombre=M.USUARIO_NOMBRE AND U.apellido = USUARIO_APELLIDO
		JOIN ESECUELE.LOCALIDAD L ON L.nombre + (SELECT nombre from ESECUELE.PROVINCIA P WHERE P.id_provincia = L.provincia_id ) = M.ENVIO_MENSAJERIA_LOCALIDAD + M.ENVIO_MENSAJERIA_PROVINCIA
		JOIN ESECUELE.TIPO_PAQUETE T ON T.tipo = M.PAQUETE_TIPO
		JOIN ESECUELE.REPARTIDOR R ON R.dni=M.REPARTIDOR_DNI AND R.nombre=M.REPARTIDOR_NOMBRE AND R.apellido = M.REPARTIDOR_APELLIDO
		JOIN ESECUELE.MEDIO_DE_PAGO MP ON MP.usuario_id = U.id_usuario AND MP.nro_tarjeta = M.MEDIO_PAGO_NRO_TARJETA  AND  MP.marca_tarjeta = M.MARCA_TARJETA
		JOIN ESECUELE.ESTADO_ENVIO E ON E.estado = M.ENVIO_MENSAJERIA_ESTADO

END
GO


CREATE PROCEDURE CREAR_OPERADORES
AS
BEGIN

	INSERT INTO ESECUELE.OPERADOR (nombre,apellido,DNI,telefono,direccion,mail,fecha_nacimiento)
		SELECT DISTINCT
		M.OPERADOR_RECLAMO_NOMBRE,
		M.OPERADOR_RECLAMO_APELLIDO,
		M.OPERADOR_RECLAMO_DNI,
		M.OPERADOR_RECLAMO_TELEFONO,
		M.OPERADOR_RECLAMO_DIRECCION,
		M.OPERADOR_RECLAMO_MAIL,
		M.OPERADOR_RECLAMO_FECHA_NAC
		FROM
		gd_esquema.Maestra M
		WHERE
		M.OPERADOR_RECLAMO_NOMBRE IS NOT NULL

END
GO


CREATE PROCEDURE CREAR_PEDIDOS
AS
BEGIN

	-- Creamos los estados de pedidos --
	INSERT INTO ESECUELE.ESTADO_PEDIDO (estado)
		SELECT DISTINCT
		M.PEDIDO_ESTADO
		FROM
		gd_esquema.Maestra M
		GROUP BY
		M.PEDIDO_ESTADO

	-- Creamos los pedidos --
	INSERT INTO ESECUELE.PEDIDO (id_pedido,usuario_id,local_id,medio_de_pago_id,observaciones,estado_pedido_id,fecha_entrega,tiempo_estimado_entrega,calificacion,total_pedido,total_cupones)
		SELECT DISTINCT
		M.PEDIDO_NRO,
		U.id_usuario,
		L.id_local,
		MP.id_medio_de_pago,
		M.PEDIDO_OBSERV,
		PE.id_estado_pedido,
		M.PEDIDO_FECHA_ENTREGA,
		M.PEDIDO_TIEMPO_ESTIMADO_ENTREGA,
		M.PEDIDO_CALIFICACION,
		M.PEDIDO_TOTAL_PRODUCTOS + M.PEDIDO_TOTAL_SERVICIO + M.PEDIDO_TOTAL_CUPONES - M.PEDIDO_PROPINA,
		M.PEDIDO_TOTAL_CUPONES
		FROM
		gd_esquema.Maestra M
		JOIN ESECUELE.USUARIO U ON U.dni=M.USUARIO_DNI AND U.nombre=M.USUARIO_NOMBRE AND U.apellido = M.USUARIO_APELLIDO
		JOIN ESECUELE.LOCAL L ON L.nombre + L.descripcion = M.LOCAL_NOMBRE + M.LOCAL_DESCRIPCION
		JOIN ESECUELE.DIRECCION_USUARIO DU ON DU.direccion = M.DIRECCION_USUARIO_DIRECCION
		JOIN ESECUELE.MEDIO_DE_PAGO MP ON MP.usuario_id = U.id_usuario AND MP.nro_tarjeta + MP.marca_tarjeta = M.MEDIO_PAGO_NRO_TARJETA + M.MARCA_TARJETA
		JOIN ESECUELE.ESTADO_PEDIDO PE ON PE.estado = M.PEDIDO_ESTADO
		JOIN ESECUELE.LOCALIDAD LO ON LO.id_localidad = L.localidad_id
		WHERE
		LO.nombre = M.LOCAL_LOCALIDAD

	-- Creamos los productos para cada pedido --
	INSERT INTO ESECUELE.PRODUCTO_PEDIDO (id_producto,nro_pedido,cantidad,precio_al_comprar,total_productos)
		SELECT DISTINCT
		PR.id_producto,
		PE.id_pedido,
		M.PRODUCTO_CANTIDAD,
		M.PRODUCTO_LOCAL_PRECIO,
		M.PRODUCTO_CANTIDAD * M.PRODUCTO_LOCAL_PRECIO
		FROM
		gd_esquema.Maestra M
		JOIN ESECUELE.PRODUCTO PR ON PR.codigo = M.PRODUCTO_LOCAL_CODIGO
		JOIN ESECUELE.PEDIDO PE ON M.PEDIDO_NRO = PE.id_pedido


END
GO



CREATE PROCEDURE CREAR_ENVIOS
AS
BEGIN

	INSERT INTO ESECUELE.ENVIO (fecha_pedido,direccion_usuario_id,tarifa_servicio,propina,repartidor_id,precio_envio,pedido_id)
		SELECT DISTINCT
		M.PEDIDO_FECHA,
		DU.id_direccion_usuario,
		M.PEDIDO_TARIFA_SERVICIO,
		M.PEDIDO_PROPINA,
		R.id_repartidor,
		M.PEDIDO_PRECIO_ENVIO,
		P.id_pedido
		FROM
		gd_esquema.Maestra M
		JOIN ESECUELE.DIRECCION_USUARIO DU ON M.DIRECCION_USUARIO_DIRECCION = DU.direccion
		JOIN ESECUELE.LOCALIDAD L ON DU.localidad_id = L.id_localidad
		JOIN ESECUELE.REPARTIDOR R ON R.dni=M.REPARTIDOR_DNI AND R.nombre=M.REPARTIDOR_NOMBRE AND R.apellido = M.REPARTIDOR_APELLIDO
		JOIN ESECUELE.PEDIDO P ON P.id_pedido = M.PEDIDO_NRO
		WHERE M.DIRECCION_USUARIO_DIRECCION + M.DIRECCION_USUARIO_LOCALIDAD  = DU.direccion + L.nombre

END
GO


CREATE PROCEDURE CREAR_RECLAMOS
AS
BEGIN
	-- Creamos los tipos de estados de reclamo --
	INSERT INTO ESECUELE.ESTADO_RECLAMO (M.nombre)
		SELECT DISTINCT
		M.RECLAMO_ESTADO
		FROM
		gd_esquema.Maestra M
		GROUP BY
		M.RECLAMO_ESTADO

	-- Creamos los reclamos --
	INSERT INTO ESECUELE.RECLAMO (id_reclamo,usuario_id,pedido_id,tipo,descr,fecha_hora,operador_id,estado_reclamo_id,solucion,fecha_hora_solucion,calificacion)
	SELECT
		M.RECLAMO_NRO,
		U.id_usuario,
		P.id_pedido,
		M.RECLAMO_TIPO,
		M.RECLAMO_DESCRIPCION,
		M.RECLAMO_FECHA,
		O.id_operador,
		ER.id_estado_reclamo,
		M.RECLAMO_SOLUCION,
		M.RECLAMO_FECHA_SOLUCION,
		M.RECLAMO_CALIFICACION
	FROM
		gd_esquema.Maestra M
	JOIN
		ESECUELE.USUARIO U ON U.dni=M.USUARIO_DNI AND U.nombre=M.USUARIO_NOMBRE AND U.apellido = M.USUARIO_APELLIDO
	JOIN
		ESECUELE.PEDIDO P ON P.id_pedido = M.PEDIDO_NRO
	JOIN
		ESECUELE.ENVIO E ON E.pedido_id = P.id_pedido
	JOIN
		ESECUELE.LOCAL L ON L.id_local = P.local_id AND L.nombre = M.LOCAL_NOMBRE
	JOIN
		ESECUELE.OPERADOR O ON O.DNI = M.OPERADOR_RECLAMO_DNI AND O.nombre = M.OPERADOR_RECLAMO_NOMBRE AND O.apellido = M.OPERADOR_RECLAMO_APELLIDO
	JOIN
		ESECUELE.ESTADO_RECLAMO ER ON M.RECLAMO_ESTADO = ER.nombre

	INSERT INTO ESECUELE.CUPON_RECLAMO
		SELECT
		id_cupon,
		id_reclamo
		FROM
		gd_esquema.Maestra M
		JOIN ESECUELE.CUPON C ON M.CUPON_NRO = C.id_cupon
		JOIN ESECUELE.RECLAMO R ON M.RECLAMO_NRO = R.id_reclamo
END
GO

CREATE PROCEDURE CREAR_CUPONES
AS
BEGIN

	-- Agregamos los tipos de cupones --
	INSERT INTO ESECUELE.TIPO_CUPON (tipo)
		SELECT DISTINCT
		M.CUPON_TIPO
		FROM
		gd_esquema.Maestra M


	-- Agregamos los cupones --
	INSERT INTO ESECUELE.CUPON (id_cupon,usuario_id,fecha_alta,fecha_vencimiento,tipo_cupon_id,descuento)
		SELECT
		a1,a2,a3,a4,a5,a6
		FROM
			(
			SELECT DISTINCT
			M.CUPON_NRO a1,
			U.id_usuario a2,
			M.CUPON_FECHA_ALTA a3,
			M.CUPON_FECHA_VENCIMIENTO a4,
			TC.id_tipo_cupon a5,
			M.CUPON_MONTO a6,
			ROW_NUMBER() OVER (PARTITION BY M.CUPON_NRO ORDER BY U.id_usuario) rn
			FROM
			gd_esquema.Maestra M
			JOIN ESECUELE.USUARIO U ON U.dni=M.USUARIO_DNI AND U.nombre=M.USUARIO_NOMBRE AND U.apellido = M.USUARIO_APELLIDO
			JOIN ESECUELE.TIPO_CUPON TC ON M.CUPON_TIPO = TC.tipo
			) X
		WHERE X.rn = 1


	-- Agregamos los cupones de cada usuario aplicados --
	INSERT INTO ESECUELE.CUPON_APLICADO
		SELECT DISTINCT
		C.id_cupon,
		P.id_pedido
		FROM
		gd_esquema.Maestra M
		JOIN ESECUELE.CUPON C ON C.id_cupon = M.CUPON_NRO
		JOIN ESECUELE.PEDIDO P ON M.PEDIDO_NRO = P.id_pedido


END
GO



EXECUTE CREAR_LOCALIDADES
EXECUTE CREAR_USUARIOS
EXECUTE CREAR_LOCALES
EXECUTE CREAR_REPARTIDORES
EXECUTE CREAR_ENVIO_MENSAJERIA
EXECUTE CREAR_OPERADORES
EXECUTE CREAR_ENVIOS
EXECUTE CREAR_PEDIDOS
EXECUTE CREAR_RECLAMOS
EXECUTE CREAR_CUPONES

DROP TABLE ##LOCALIDAD_PROVINCIA

DROP PROCEDURE CREAR_LOCALIDADES
DROP PROCEDURE CREAR_USUARIOS
DROP PROCEDURE CREAR_LOCALES
DROP PROCEDURE CREAR_REPARTIDORES
DROP PROCEDURE CREAR_ENVIO_MENSAJERIA
DROP PROCEDURE CREAR_OPERADORES
DROP PROCEDURE CREAR_ENVIOS
DROP PROCEDURE CREAR_PEDIDOS
DROP PROCEDURE CREAR_RECLAMOS
DROP PROCEDURE CREAR_CUPONES
GO


SELECT * FROM ESECUELE.PROVINCIA;
SELECT * FROM ESECUELE.LOCALIDAD;
SELECT * FROM ESECUELE.USUARIO;
SELECT * FROM ESECUELE.DIRECCION_USUARIO;
SELECT * FROM ESECUELE.ESTADO_RECLAMO;
SELECT * FROM ESECUELE.OPERADOR;
SELECT * FROM ESECUELE.TIPO_CUPON;
SELECT * FROM ESECUELE.CUPON;
SELECT * FROM ESECUELE.TIPO_MOVILIDAD;
SELECT * FROM ESECUELE.REPARTIDOR;
SELECT * FROM ESECUELE.TIPO_LOCAL;
SELECT * FROM ESECUELE.CATEGORIA_LOCAL;
SELECT * FROM ESECUELE.LOCAL;
SELECT * FROM ESECUELE.HORARIOS_LOCAL;
SELECT * FROM ESECUELE.MEDIO_DE_PAGO;
SELECT * FROM ESECUELE.ESTADO_PEDIDO;
SELECT * FROM ESECUELE.PEDIDO;
SELECT * FROM ESECUELE.ENVIO;











