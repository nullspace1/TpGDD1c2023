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
id_cupon INT IDENTITY(1,1) NOT NULL,
fecha_alta DATE,
fecha_vencimiento DATE,
tipo_cupon_id INT NOT NULL,
descuento DECIMAL(18,2),

PRIMARY KEY (id_cupon),
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
tipo_movilidad_id int NOT NULL,
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
tipo_local_id INT NOT NULL

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
local_id INT NOT NULL,
horario_hora_apertura DECIMAL(18,0),
horario_hora_cierre  DECIMAL(18,0),
horario_hora_dia NVARCHAR(50),

PRIMARY KEY(id_horario_local),
FOREIGN KEY(local_id) REFERENCES ESECUELE.LOCAL(id_local)
)



CREATE TABLE ESECUELE.MEDIO_DE_PAGO(
id_medio_de_pago INT IDENTITY(1,1) NOT NULL ,
tipo NVARCHAR(50),


PRIMARY KEY(id_medio_de_pago)
);

CREATE TABLE ESECUELE.MEDIO_DE_PAGO_USUARIO(
medio_de_pago_id INT NOT NULL,
usuario_id INT NOT NULL,

PRIMARY KEY(medio_de_pago_id, usuario_id),
FOREIGN KEY(medio_de_pago_id) REFERENCES ESECUELE.MEDIO_DE_PAGO(id_medio_de_pago),
FOREIGN KEY(usuario_id) REFERENCES ESECUELE.USUARIO(id_usuario)
)

CREATE TABLE ESECUELE.TARJETA(
id_tarjeta INT IDENTITY(1,1) NOT NULL,
nro_tarjeta NVARCHAR(50),
usuario_id int NOT NULL,
marca_tarjeta NVARCHAR(100)

PRIMARY KEY(id_tarjeta),
FOREIGN KEY (usuario_id) REFERENCES ESECUELE.USUARIO(id_usuario)
)

CREATE TABLE ESECUELE.ESTADO_PEDIDO(
id_estado_pedido INT IDENTITY(1,1) NOT NULL ,
estado NVARCHAR(50),

PRIMARY KEY(id_estado_pedido)
);


CREATE TABLE ESECUELE.PEDIDO(
id_pedido INT IDENTITY(1,1) NOT NULL ,
usuario_id int NOT NULL,
local_id int NOT NULL,
tarjeta_id int NOT NULL,
observaciones NVARCHAR(255),
fecha_pedido DATETIME2,
calificacion DECIMAL(18,0),
total_pedido DECIMAL(18,2),
total_cupones DECIMAL(18,2),
estado_pedido_id INT NOT NULL,


PRIMARY KEY (id_pedido),
FOREIGN KEY (local_id) REFERENCES ESECUELE.local(id_local),
FOREIGN KEY (tarjeta_id) REFERENCES ESECUELE.TARJETA(id_tarjeta),
FOREIGN KEY (usuario_id) REFERENCES ESECUELE.usuario(id_usuario),
FOREIGN KEY (estado_pedido_id) REFERENCES ESECUELE.ESTADO_PEDIDO (id_estado_pedido)
);

CREATE TABLE ESECUELE.ENVIO(
id_envio INT IDENTITY(1,1) NOT NULL ,
pedido_id INT NOT NULL,
fecha_pedido DATETIME2(3),
fecha_entrega DATETIME2(3),
tiempo_estimado_entrega decimal(18,0),
direccion_usuario_id int NOT NULL,
tarifa_servicio int,
propina DECIMAL(18,2),
repartidor_id int NOT NULL,
precio_envio DECIMAL(18,2),

PRIMARY KEY (id_envio),
FOREIGN KEY (repartidor_id) REFERENCES ESECUELE.repartidor(id_repartidor),
FOREIGN KEY (pedido_id) REFERENCES ESECUELE.pedido(id_pedido),
FOREIGN KEY(direccion_usuario_id) REFERENCES ESECUELE.DIRECCION_USUARIO(id_direccion_usuario)
);


CREATE TABLE ESECUELE.CUPON_APLICADO(
cupon_id INT  NOT NULL ,
pedido_id INT NOT NULL ,

PRIMARY KEY (cupon_id,pedido_id),
FOREIGN KEY (cupon_id) REFERENCES ESECUELE.cupon(id_cupon),
FOREIGN KEY (pedido_id) REFERENCES ESECUELE.pedido(id_pedido)
);


CREATE TABLE ESECUELE.PRODUCTO(
id_producto INT IDENTITY(1,1) NOT NULL ,
local_id INT NOT NULL,
codigo NVARCHAR(255),
nombre NVARCHAR(255),
descripcion NVARCHAR(255),
precio_unitaro DECIMAL(18,2),

FOREIGN KEY (local_id) REFERENCES ESECUELE.LOCAL(id_local),
PRIMARY KEY (id_producto)
);

CREATE TABLE ESECUELE.PRODUCTO_PEDIDO(
id_producto INT NOT NULL ,
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

CREATE TABLE ESECUELE.ESTADO_ENVIO_MENSAJERIA (
id_estado_envio INT IDENTITY(1,1) NOT NULL,
estado nvarchar(50),

PRIMARY KEY (id_estado_envio)
)

CREATE TABLE ESECUELE.ENVIO_MENSAJERIA (
id_envio INT IDENTITY(1,1) NOT NULL ,
usuario_id INT NOT NULL,
dir_origen NVARCHAR(255),
dir_destino NVARCHAR(255),
distancia_km DECIMAL(18,2),
localidad_id INT NOT NULL,
tipo_paquete_id INT NOT NULL,
valor_asegurado DECIMAL(18,2),
observaciones NVARCHAR(255),
precio_envio DECIMAL(18,2),
precio_seguro DECIMAL(18,2),
repartidor_id INT NOT NULL,
propina DECIMAL(18,2),
tarjeta_id INT NOT NULL,
fecha_hora_entrega DATETIME2(3),
fecha_hora_pedido DATETIME2(3),
calificacion DECIMAL(18,0),
total DECIMAL(18,2),
estado_id INT NOT NULL,
tiempo_estimado DECIMAL(18,2),
PRIMARY KEY(id_envio),
FOREIGN KEY(usuario_id) REFERENCES ESECUELE.USUARIO (id_usuario),
FOREIGN KEY(localidad_id) REFERENCES ESECUELE.LOCALIDAD (id_localidad),
FOREIGN KEY(tipo_paquete_id) REFERENCES ESECUELE.TIPO_PAQUETE (id_tipo_paquete),
FOREIGN KEY(repartidor_id) REFERENCES ESECUELE.REPARTIDOR (id_repartidor),
FOREIGN KEY(tarjeta_id) REFERENCES ESECUELE.TARJETA (id_tarjeta),
FOREIGN KEY(estado_id) REFERENCES ESECUELE.ESTADO_ENVIO_MENSAJERIA (id_estado_envio)
);

CREATE TABLE ESECUELE.TIPO_RECLAMO(
	id_tipo_reclamo INT IDENTITY(1,1) NOT NULL,
	tipo NVARCHAR(255)
	PRIMARY KEY(id_tipo_reclamo)
);

CREATE TABLE ESECUELE.RECLAMO(
id_reclamo INT IDENTITY(1,1) NOT NULL ,
usuario_id INT NOT NULL,
pedido_id INT NOT NULL,
tipo_reclamo_id INT NOT NULL,
descr NVARCHAR(255),
fecha_hora DATETIME2(3),
operador_id INT NOT NULL,
estado_reclamo_id INT NOT NULL,
solucion NVARCHAR(255),
fecha_hora_solucion DATE,
calificacion INT,

PRIMARY KEY(id_reclamo),
FOREIGN KEY(usuario_id) REFERENCES ESECUELE.USUARIO (id_usuario),
FOREIGN KEY(pedido_id) REFERENCES ESECUELE.PEDIDO (id_pedido),
FOREIGN KEY(operador_id) REFERENCES ESECUELE.OPERADOR (id_operador),
FOREIGN KEY(estado_reclamo_id) REFERENCES ESECUELE.ESTADO_RECLAMO (id_estado_reclamo),
FOREIGN KEY(tipo_reclamo_id) REFERENCES ESECUELE.TIPO_RECLAMO (id_tipo_reclamo)
);

CREATE TABLE ESECUELE.CUPON_RECLAMO(
cupon_id INT  NOT NULL ,
reclamo_id INT  NOT NULL ,

PRIMARY KEY(cupon_id,reclamo_id),
FOREIGN KEY (cupon_id) REFERENCES ESECUELE.CUPON (id_cupon),
FOREIGN KEY (reclamo_id) REFERENCES ESECUELE.RECLAMO (id_reclamo)
);

CREATE TABLE ESECUELE.CUPON_USUARIO (
	cupon_id INT NOT NULL,
	usuario_id INT NOT NULL
	PRIMARY KEY(cupon_id,usuario_id),
	FOREIGN KEY (cupon_id) REFERENCES ESECUELE.CUPON (id_cupon),
	FOREIGN KEY (usuario_id) REFERENCES ESECUELE.USUARIO (id_usuario)
);
GO

COMMIT
GO

BEGIN TRANSACTION

	CREATE INDEX idx_user
	ON gd_esquema.Maestra (USUARIO_DNI)

	CREATE INDEX idx_envio_nro
	ON [gd_esquema].[Maestra] (USUARIO_DNI, 
	USUARIO_NOMBRE) INCLUDE 
	(
	ENVIO_MENSAJERIA_DIR_ORIG,
	ENVIO_MENSAJERIA_DIR_DEST,
	ENVIO_MENSAJERIA_KM,
	ENVIO_MENSAJERIA_VALOR_ASEGURADO,
	ENVIO_MENSAJERIA_OBSERV,
	ENVIO_MENSAJERIA_PRECIO_ENVIO,
	ENVIO_MENSAJERIA_PRECIO_SEGURO,
	ENVIO_MENSAJERIA_PROPINA,
	ENVIO_MENSAJERIA_TIEMPO_ESTIMADO
	)


	INSERT INTO ESECUELE.PROVINCIA (nombre)
		SELECT DISTINCT
		M.LOCAL_PROVINCIA
		FROM
		gd_esquema.Maestra M
		WHERE M.LOCAL_PROVINCIA IS NOT NULL


	INSERT INTO ESECUELE.LOCALIDAD (nombre,provincia_id)
		SELECT DISTINCT
		M.DIRECCION_USUARIO_LOCALIDAD,
		ESECUELE.PROVINCIA.id_provincia
		FROM
		gd_esquema.Maestra M
		JOIN
		ESECUELE.PROVINCIA ON M.DIRECCION_USUARIO_PROVINCIA = ESECUELE.PROVINCIA.nombre

	INSERT INTO ESECUELE.LOCALIDAD (nombre,provincia_id)
		SELECT DISTINCT 
		M.ENVIO_MENSAJERIA_LOCALIDAD,
		P.id_provincia
		FROM
		gd_esquema.Maestra M
		JOIN
		ESECUELE.PROVINCIA P ON M.ENVIO_MENSAJERIA_LOCALIDAD = P.nombre
		WHERE
		M.ENVIO_MENSAJERIA_LOCALIDAD NOT IN (SELECT nombre FROM ESECUELE.LOCALIDAD L WHERE  L.provincia_id = P.id_provincia)


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

	INSERT INTO ESECUELE.DIRECCION_USUARIO (localidad_id,usuario_id,direccion)
		SELECT DISTINCT
		L.id_localidad,
		U.id_usuario,
		M.DIRECCION_USUARIO_DIRECCION
		FROM
		gd_esquema.Maestra M
		JOIN
		ESECUELE.USUARIO U ON U.dni=M.USUARIO_DNI AND U.nombre=M.USUARIO_NOMBRE 
		JOIN
		ESECUELE.PROVINCIA P ON M.DIRECCION_USUARIO_PROVINCIA = P.nombre
		JOIN
		ESECUELE.LOCALIDAD L ON M.DIRECCION_USUARIO_LOCALIDAD = L.nombre
		WHERE
		L.provincia_id = P.id_provincia

	INSERT INTO ESECUELE.MEDIO_DE_PAGO (tipo)
		SELECT DISTINCT
		M.MEDIO_PAGO_TIPO
		FROM
		gd_esquema.Maestra M
		JOIN ESECUELE.USUARIO U ON U.dni=M.USUARIO_DNI AND U.nombre=M.USUARIO_NOMBRE

	INSERT INTO ESECUELE.MEDIO_DE_PAGO_USUARIO (medio_de_pago_id,usuario_id)
		SELECT DISTINCT
		MP.id_medio_de_pago,
		U.id_usuario
		FROM
		gd_esquema.Maestra M
		JOIN ESECUELE.MEDIO_DE_PAGO MP ON MP.tipo = M.MEDIO_PAGO_TIPO
		JOIN ESECUELE.USUARIO U ON U.dni = M.USUARIO_DNI AND U.nombre  = M.USUARIO_NOMBRE 

	INSERT INTO ESECUELE.TARJETA (nro_tarjeta,marca_tarjeta,usuario_id)
		SELECT DISTINCT
		M.MEDIO_PAGO_NRO_TARJETA,
		M.MARCA_TARJETA,
		U.id_usuario
		FROM
		gd_esquema.Maestra M
		JOIN ESECUELE.USUARIO U ON U.dni=M.USUARIO_DNI AND U.nombre=M.USUARIO_NOMBRE 

	INSERT INTO ESECUELE.TIPO_LOCAL (tipo)
		SELECT DISTINCT
		M.LOCAL_TIPO
		FROM
		gd_esquema.Maestra M
		WHERE
		M.LOCAL_TIPO IS NOT NULL

	INSERT INTO ESECUELE.CATEGORIA_LOCAL (categoria, tipo_local_id) VALUES
		('Restaurante Italiano', 1),
		('Restaurante Chino', 1),
		('Restaurante Mexicano', 1),
		('Restaurante Indio', 1),
		('Restaurante Tailandes', 1),
		('Frutas y Verduras', 2),
		('Carnes y Pescados', 2),
		('Panaderia', 2),
		('Lacteos', 2),
		('Especias y Hierbas', 2);

	INSERT INTO ESECUELE.LOCAL (categoria_local_id, tipo_local_id, nombre, descripcion, direccion, localidad_id)
    SELECT DISTINCT
        (SELECT TOP 1 CL.id_categoria_local
         FROM ESECUELE.CATEGORIA_LOCAL CL
         WHERE CL.tipo_local_id = TL.id_tipo_local
         ORDER BY NEWID()),
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
    WHERE L.provincia_id = P.id_provincia;


	INSERT INTO ESECUELE.HORARIOS_LOCAL (local_id,horario_hora_apertura,horario_hora_cierre,horario_hora_dia)
		SELECT DISTINCT
		L.id_local,
		M.HORARIO_LOCAL_HORA_APERTURA,
		M.HORARIO_LOCAL_HORA_CIERRE,
		M.HORARIO_LOCAL_DIA
		FROM
		gd_esquema.Maestra M
		JOIN ESECUELE.LOCAL L ON M.LOCAL_NOMBRE + M.LOCAL_DIRECCION  = L.nombre + L.direccion
		JOIN ESECUELE.LOCALIDAD LOC ON LOC.id_localidad = L.localidad_id AND LOC.nombre = M.LOCAL_LOCALIDAD

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
		LO.id_localidad = L.localidad_id AND PRODUCTO_LOCAL_CODIGO IS NOT NULL

	INSERT INTO ESECUELE.TIPO_MOVILIDAD (nombre)
		SELECT DISTINCT
		M.REPARTIDOR_TIPO_MOVILIDAD
		FROM
		gd_esquema.Maestra M

	INSERT INTO ESECUELE.REPARTIDOR (nombre,apellido,dni,telefono,direccion,fecha_nac,tipo_movilidad_id,localidad_id,email)
		SELECT DISTINCT
		M.REPARTIDOR_NOMBRE,
		M.REPARTIDOR_APELLIDO,
		M.REPARTIDOR_DNI,
		M.REPARTIDOR_TELEFONO,
		M.REPARTIDOR_DIRECION,
		M.REPARTIDOR_FECHA_NAC,
		TM.id_tipo_movilidad,
		NULL,
		M.REPARTIDOR_EMAIL
		FROM
		gd_esquema.Maestra M
		JOIN ESECUELE.TIPO_MOVILIDAD TM ON M.REPARTIDOR_TIPO_MOVILIDAD = TM.nombre

	INSERT INTO ESECUELE.ESTADO_ENVIO_MENSAJERIA (estado)
		SELECT DISTINCT
		M.ENVIO_MENSAJERIA_ESTADO
		FROM
		gd_esquema.Maestra M
		WHERE
		M.ENVIO_MENSAJERIA_ESTADO IS NOT NULL

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
		WHERE
		M.PAQUETE_TIPO IS NOT NULL


	INSERT INTO ESECUELE.ENVIO_MENSAJERIA (usuario_id,dir_origen,dir_destino,distancia_km,localidad_id,tipo_paquete_id,valor_asegurado,
											observaciones,precio_envio,precio_seguro,repartidor_id,propina,tarjeta_id,
											fecha_hora_entrega,fecha_hora_pedido,calificacion,total,estado_id,tiempo_estimado)
		SELECT DISTINCT
		U.id_usuario,
		M.ENVIO_MENSAJERIA_DIR_ORIG,
		M.ENVIO_MENSAJERIA_DIR_DEST,
		M.ENVIO_MENSAJERIA_KM,
		L.id_localidad,
		TP.id_tipo_paquete,
		M.ENVIO_MENSAJERIA_VALOR_ASEGURADO,
		M.ENVIO_MENSAJERIA_OBSERV,
		M.ENVIO_MENSAJERIA_PRECIO_ENVIO,
		M.ENVIO_MENSAJERIA_PRECIO_SEGURO,
		R.id_repartidor,
		M.ENVIO_MENSAJERIA_PROPINA,
		T.id_tarjeta,
		M.ENVIO_MENSAJERIA_FECHA_ENTREGA,
		M.ENVIO_MENSAJERIA_FECHA,
		M.ENVIO_MENSAJERIA_CALIFICACION,
		M.ENVIO_MENSAJERIA_TOTAL,
		EV.id_estado_envio,
		M.ENVIO_MENSAJERIA_TIEMPO_ESTIMADO
		FROM
		gd_esquema.Maestra M
		JOIN ESECUELE.USUARIO U ON  M.ENVIO_MENSAJERIA_NRO IS NOT NULL AND U.dni=M.USUARIO_DNI AND U.nombre=M.USUARIO_NOMBRE
		JOIN ESECUELE.TARJETA T ON T.usuario_id = U.id_usuario AND T.nro_tarjeta = M.MEDIO_PAGO_NRO_TARJETA
		JOIN ESECUELE.PROVINCIA P ON M.ENVIO_MENSAJERIA_PROVINCIA = P.nombre
		JOIN ESECUELE.LOCALIDAD L ON M.ENVIO_MENSAJERIA_LOCALIDAD = L.nombre and L.provincia_id = P.id_provincia
		JOIN ESECUELE.TIPO_PAQUETE TP ON M.PAQUETE_TIPO = TP.tipo
		JOIN ESECUELE.REPARTIDOR R ON M.REPARTIDOR_DNI = R.dni
		JOIN ESECUELE.ESTADO_ENVIO_MENSAJERIA EV ON M.ENVIO_MENSAJERIA_ESTADO = EV.estado



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


	INSERT INTO ESECUELE.ESTADO_PEDIDO (estado)
		SELECT DISTINCT
		M.PEDIDO_ESTADO
		FROM
		gd_esquema.Maestra M
		WHERE M.PEDIDO_ESTADO IS NOT NULL

	SET IDENTITY_INSERT ESECUELE.PEDIDO ON

	INSERT INTO ESECUELE.PEDIDO (id_pedido,usuario_id,local_id,tarjeta_id,observaciones,estado_pedido_id,fecha_pedido,calificacion,total_pedido,total_cupones)
		SELECT DISTINCT
		M.PEDIDO_NRO,
		U.id_usuario,
		L.id_local,
		T.id_tarjeta,
		M.PEDIDO_OBSERV,
		PE.id_estado_pedido,
		M.PEDIDO_FECHA,
		M.PEDIDO_CALIFICACION,
		M.PEDIDO_TOTAL_PRODUCTOS + M.PEDIDO_TOTAL_SERVICIO + M.PEDIDO_TOTAL_CUPONES - M.PEDIDO_PROPINA,
		M.PEDIDO_TOTAL_CUPONES
		FROM
		gd_esquema.Maestra M
		JOIN ESECUELE.ESTADO_PEDIDO PE ON PE.estado = M.PEDIDO_ESTADO
		JOIN ESECUELE.TARJETA T ON T.nro_tarjeta = M.MEDIO_PAGO_NRO_TARJETA
		JOIN ESECUELE.PROVINCIA P ON M.LOCAL_PROVINCIA = P.nombre
		JOIN ESECUELE.LOCALIDAD LO ON M.LOCAL_LOCALIDAD = LO.nombre AND P.id_provincia = LO.provincia_id
		JOIN ESECUELE.LOCAL L ON L.nombre = M.LOCAL_NOMBRE AND L.localidad_id = LO.id_localidad
		JOIN ESECUELE.USUARIO U ON U.dni=M.USUARIO_DNI AND U.nombre=M.USUARIO_NOMBRE 
		WHERE
		M.PEDIDO_NRO IS NOT NULL

	SET IDENTITY_INSERT ESECUELE.PEDIDO OFF

	INSERT INTO ESECUELE.PRODUCTO_PEDIDO (id_producto,nro_pedido,cantidad,precio_al_comprar,total_productos)
		SELECT DISTINCT
		PR.id_producto,
		PE.id_pedido,
		SUM(M.PRODUCTO_CANTIDAD),
		SUM(M.PRODUCTO_LOCAL_PRECIO),
		SUM(M.PRODUCTO_CANTIDAD * M.PRODUCTO_LOCAL_PRECIO)
		FROM
		gd_esquema.Maestra M
		JOIN ESECUELE.PRODUCTO PR ON PR.codigo = M.PRODUCTO_LOCAL_CODIGO
		JOIN ESECUELE.PEDIDO PE ON M.PEDIDO_NRO = PE.id_pedido
		WHERE
		M.PEDIDO_NRO IS NOT NULL
		GROUP BY
		PR.id_producto,
		PE.id_pedido


	INSERT INTO ESECUELE.ENVIO (fecha_entrega,fecha_pedido,tiempo_estimado_entrega,direccion_usuario_id,tarifa_servicio,propina,repartidor_id,precio_envio,pedido_id)
		SELECT DISTINCT
		M.PEDIDO_FECHA_ENTREGA,
		M.PEDIDO_FECHA,
		M.PEDIDO_TIEMPO_ESTIMADO_ENTREGA,
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

	INSERT INTO ESECUELE.ESTADO_RECLAMO (M.nombre)
		SELECT DISTINCT
		M.RECLAMO_ESTADO
		FROM
		gd_esquema.Maestra M
		WHERE
		M.RECLAMO_ESTADO IS NOT NULL

	INSERT INTO ESECUELE.TIPO_RECLAMO (tipo)
		SELECT DISTINCT
		M.RECLAMO_TIPO
		FROM
		gd_esquema.Maestra M
		WHERE
		M.RECLAMO_TIPO IS NOT NULL


	SET IDENTITY_INSERT ESECUELE.RECLAMO ON


	INSERT INTO ESECUELE.RECLAMO (id_reclamo,usuario_id,pedido_id,tipo_reclamo_id,descr,fecha_hora,operador_id,estado_reclamo_id,solucion,fecha_hora_solucion,calificacion)
		SELECT DISTINCT
		M.RECLAMO_NRO,
		U.id_usuario,
		P.id_pedido,
		TR.id_tipo_reclamo,
		M.RECLAMO_DESCRIPCION,
		M.RECLAMO_FECHA,
		O.id_operador,
		ER.id_estado_reclamo,
		M.RECLAMO_SOLUCION,
		M.RECLAMO_FECHA_SOLUCION,
		M.RECLAMO_CALIFICACION
		FROM
		gd_esquema.Maestra M
		JOIN ESECUELE.USUARIO U ON U.dni=M.USUARIO_DNI AND U.nombre=M.USUARIO_NOMBRE
		JOIN ESECUELE.PEDIDO P ON P.id_pedido = M.PEDIDO_NRO
		JOIN ESECUELE.ENVIO E ON E.pedido_id = P.id_pedido
		JOIN ESECUELE.LOCAL L ON L.id_local = P.local_id AND L.nombre = M.LOCAL_NOMBRE
		JOIN ESECUELE.OPERADOR O ON O.DNI = M.OPERADOR_RECLAMO_DNI AND O.nombre = M.OPERADOR_RECLAMO_NOMBRE AND O.apellido = M.OPERADOR_RECLAMO_APELLIDO
		JOIN ESECUELE.ESTADO_RECLAMO ER ON M.RECLAMO_ESTADO = ER.nombre
		JOIN ESECUELE.TIPO_RECLAMO TR ON M.RECLAMO_TIPO = TR.tipo
		WHERE
		M.RECLAMO_NRO IS NOT NULL

	SET IDENTITY_INSERT ESECUELE.RECLAMO OFF



	INSERT INTO ESECUELE.TIPO_CUPON (tipo)
		SELECT DISTINCT
		M.CUPON_TIPO
		FROM
		gd_esquema.Maestra M
		WHERE M.CUPON_TIPO is not null


	SET IDENTITY_INSERT ESECUELE.CUPON ON


	INSERT INTO ESECUELE.CUPON (id_cupon,fecha_alta,fecha_vencimiento,tipo_cupon_id,descuento)
		SELECT DISTINCT
		M.CUPON_NRO,
		MIN(M.CUPON_FECHA_ALTA),
		MAX(M.CUPON_FECHA_VENCIMIENTO),
		MIN(TC.id_tipo_cupon) ,
		MAX(M.CUPON_MONTO)
		FROM
		gd_esquema.Maestra M
		JOIN ESECUELE.TIPO_CUPON TC ON M.CUPON_TIPO = TC.tipo
		GROUP BY
		M.CUPON_NRO
	
	INSERT INTO ESECUELE.CUPON (id_cupon,fecha_alta,fecha_vencimiento,tipo_cupon_id,descuento)
		SELECT
		M.CUPON_RECLAMO_NRO,
		MIN(M.CUPON_RECLAMO_FECHA_ALTA),
		MAX(M.CUPON_RECLAMO_FECHA_VENCIMIENTO),
		MIN(TC.id_tipo_cupon) ,
		MAX(M.CUPON_RECLAMO_MONTO)
		FROM
		gd_esquema.Maestra M
		JOIN ESECUELE.TIPO_CUPON TC ON M.CUPON_RECLAMO_TIPO = TC.tipo
		WHERE
		M.CUPON_RECLAMO_NRO NOT IN (SELECT id_cupon FROM ESECUELE.CUPON)
		GROUP BY
		M.CUPON_RECLAMO_NRO

		SET IDENTITY_INSERT ESECUELE.CUPON OFF


	INSERT INTO ESECUELE.CUPON_APLICADO
		SELECT DISTINCT
		C.id_cupon,
		P.id_pedido
		FROM
		gd_esquema.Maestra M
		JOIN ESECUELE.CUPON C ON C.id_cupon = M.CUPON_NRO
		JOIN ESECUELE.PEDIDO P ON M.PEDIDO_NRO = P.id_pedido

	INSERT INTO ESECUELE.CUPON_RECLAMO (cupon_id,reclamo_id)
		SELECT DISTINCT
		id_cupon,
		id_reclamo
		FROM
		gd_esquema.Maestra M
		JOIN ESECUELE.CUPON C ON M.CUPON_RECLAMO_NRO = C.id_cupon
		JOIN ESECUELE.RECLAMO R ON M.RECLAMO_NRO = R.id_reclamo
		WHERE
		M.RECLAMO_NRO IS NOT NULL


		INSERT INTO ESECUELE.CUPON_USUARIO (cupon_id,usuario_id)
		SELECT DISTINCT
		id_cupon,
		id_usuario
		FROM
		gd_esquema.Maestra M
		JOIN ESECUELE.CUPON C ON M.CUPON_NRO = C.id_cupon
		JOIN ESECUELE.USUARIO U ON U.nombre  = M.USUARIO_NOMBRE  AND U.dni = M.USUARIO_DNI

COMMIT
GO


DROP INDEX idx_user ON gd_esquema.Maestra;
DROP INDEX idx_envio_nro ON gd_esquema.Maestra;
GO