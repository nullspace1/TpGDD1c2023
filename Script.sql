
CREATE TABLE LOCALIDAD(
id_localidad INT NOT NULL,
nombre VARCHAR(40),

PRIMARY KEY (id_localidad)
)

CREATE TABLE DIRECCION_USUARIO(
id_direccion_usuario INT NOT NULL,
localidad_id INT,

FOREIGN KEY (localidad_id) REFERENCES LOCALIDAD (id_localidad),
PRIMARY KEY (id_direccion_usuario)
)

CREATE TABLE USUARIO(
id_usuario INT NOT NULL,
nombre VARCHAR(50),
apellido VARCHAR(50),
dni BIGINT,
direccion_usuario int,
fecha_nac DATE,
fecha_registro DATE,
telefono VARCHAR(30),
mail VARCHAR(50),

FOREIGN KEY (direccion_usuario) REFERENCES DIRECCION_USUARIO (id_direccion_usuario),
PRIMARY KEY (id_usuario)
)

CREATE TABLE ESTADO_RECLAMO(
id_estado_reclamo INT NOT NULL,
nombre VARCHAR(50)

PRIMARY KEY(id_estado_reclamo)
)



CREATE TABLE OPERADOR (
id_operador INT NOT NULL,
nombre VARCHAR(50),
apellido VARCHAR(50),
DNI bigint,
telefono VARCHAR(50),
direccion TEXT,
mail VARCHAR(50),
fecha_nacimiento DATE

PRIMARY KEY(id_operador)
)

CREATE TABLE TIPO_CUPON(
id_tipo_cupon INT NOT NULL,
tipo VARCHAR(50),
PRIMARY KEY(id_tipo_cupon)
)

CREATE TABLE CUPON(
id_cupon INT,
usuario_id INT,
fecha_alta DATE,
fecha_vencimiento DATE,
tipo_cupon_id INT,
descuento DECIMAL(18,2)

PRIMARY KEY (id_cupon),
FOREIGN KEY (usuario_id) REFERENCES USUARIO (id_usuario),
FOREIGN KEY (tipo_cupon_id) REFERENCES TIPO_CUPON (id_tipo_cupon)
)


CREATE TABLE TIPO_MOVILIDAD(
id_tipo_movilidad int,
nombre varchar(50),
PRIMARY KEY (id_tipo_movilidad)
)

CREATE TABLE REPARTIDOR(
id_repartidor int,
nombre varchar(50),
apellido varchar(50),
dni BIGint,
telefono varchar(50),
direccion TEXT,
email varchar(50),
fecha_nac DATE,
tipo_movilidad_id int,
localidad_id int,

PRIMARY KEY (id_repartidor),
FOREIGN KEY (tipo_movilidad_id) REFERENCES tipo_movilidad(id_tipo_movilidad),
FOREIGN KEY (localidad_id) REFERENCES LOCALIDAD(id_localidad)
)

CREATE TABLE CATEGORIA_LOCAL(
id_categoria_local INT NOT NULL,
categoria VARCHAR(50)

PRIMARY KEY(id_categoria_local)
)

CREATE TABLE TIPO_LOCAL (
id_tipo_local INT NOT NULL,
tipo VARCHAR(50)

PRIMARY KEY(id_tipo_local)
)

CREATE TABLE LOCAL(
id_local INT NOT NULL,
categoria_local_id INT,
tipo_local_id INT,
nombre VARCHAR(50),
descripcion VARCHAR(50),
direccion TEXT,
localidad VARCHAR(50),
horario_hora_apertura TIME,
horario_hora_cierre TIME,
horario_hora_dia TIME,


FOREIGN KEY (tipo_local_id) REFERENCES TIPO_LOCAL(id_tipo_local),
FOREIGN KEY(categoria_local_id) REFERENCES CATEGORIA_LOCAL(id_categoria_local),
PRIMARY KEY (id_local)
)



CREATE TABLE MEDIO_DE_PAGO(
id_medio_de_pago int NOT NULL,
tipo varchar(50),
nro_tarjeta VARCHAR(16),
usuario_id int,
marca_tarjeta varchar(50),

PRIMARY KEY(id_medio_de_pago),
FOREIGN KEY (usuario_id) REFERENCES usuario(id_usuario)
)

CREATE TABLE ESTADO_ENVIO(
id_estado_envio INT NOT NULL,
estado VARCHAR(50),

PRIMARY KEY(id_estado_envio)
)

CREATE TABLE ENVIO(
id_envio int NOT NULL,
nro_pedido int,
direccion_usuario int,
tarifa_servicio int,
propina int,
repartidor_id int,
precio_envio DECIMAL(18,2),
estado_envio_id INT

PRIMARY KEY (id_envio),
FOREIGN KEY (nro_pedido) REFERENCES pedido(id_pedido),
FOREIGN KEY (repartidor_id) REFERENCES repartidor(id_repartidor),
FOREIGN KEY (estado_envio_id) REFERENCES ESTADO_ENVIO (id_estado_envio)
)

CREATE TABLE PEDIDO(
id_pedido int NOT NULL,
fecha_hora_pedido DATETIME,
usuario_id int,
local_id int,
envio_id int,
medio_de_pago_id int,
total int,
observaciones varchar (150),
estado_id int,
fecha_entrega DATETIME,
tiempo_estimado_entrega TIME,
calificacion varchar(50), -- duda
total_pedido int,
total_cupones int,

PRIMARY KEY (id_pedido),
FOREIGN KEY (local_id) REFERENCES local(id_local),
FOREIGN KEY (envio_id) REFERENCES envio(id_envio),
FOREIGN KEY (medio_de_pago_id) REFERENCES medio_de_pago(id_medio_de_pago),
FOREIGN KEY (usuario_id) REFERENCES usuario(id_usuario)
)







CREATE TABLE CUPON_APLICADO(
cupon_id int NOT NULL,
pedido_id int NOT NULL,

PRIMARY KEY (cupon_id,pedido_id),
FOREIGN KEY (cupon_id) REFERENCES cupon(id_cupon),
FOREIGN KEY (pedido_id) REFERENCES pedido(id_pedido)
)



CREATE TABLE PROVINCIA(
id_provincia int,
nombre varchar(50),
PRIMARY KEY (id_provincia)
)



----------------------


CREATE TABLE TIPO(
id_tipo INT NOT NULL,
nombre VARCHAR(40)

PRIMARY KEY (id_tipo)
)



CREATE TABLE CATEGORIA(
id_categoria INT NOT NULL,
nombre VARCHAR(40),
tipo_id INT,

FOREIGN KEY (tipo_id) REFERENCES TIPO (id_tipo),
PRIMARY KEY (id_categoria)
)

CREATE TABLE PRODUCTO(
id_producto INT NOT NULL,
local_id INT,
codigo INT,
nombre VARCHAR(50),
descripcion VARCHAR(50),
precio_unitaro DECIMAL(18,2),

FOREIGN KEY (local_id) REFERENCES LOCAL(id_local),
PRIMARY KEY (id_producto)
)

CREATE TABLE PRODUCTO_PEDIDO(
id_producto INT NOT NULL,
nro_pedido INT NOT NULL,
cantidad INT,
total_productos DECIMAL(18,2),
precio_al_comprar DECIMAL(18,2),


FOREIGN KEY (id_producto) REFERENCES PRODUCTO(id_producto),
FOREIGN KEY (nro_pedido) REFERENCES PEDIDO (id_pedido),
PRIMARY KEY (id_producto, nro_pedido)
)

CREATE TABLE TIPO_PAQUETE(
id_tipo_paquete INT NOT NULL,
tipo VARCHAR(50),
ancho decimal(18,2),
alto decimal(18,2),
largo decimal(18,2),
peso decimal(18,2),
precio decimal(18,2)

PRIMARY KEY(id_tipo_paquete)
)


-- que es FECHA_HORA en nuestro der? fecha_hora_pedido?
CREATE TABLE ENVIO_MENSAJERIA (
id_envio INT NOT NULL,
usuario_id INT,
dir_origen VARCHAR(50),
dir_destino VARCHAR(50),
distancia_km INT,
localidad_id INT,
tipo_id INT,
valor_asegurado DECIMAL(18,2),
observaciones VARCHAR(50),
precio_envio DECIMAL(18,2),
precio_seguro DECIMAL(18,2),
repartidor_id INT,
propina INT,
medio_de_pago_id INT,
fecha_hora_entrega DATETIME,
fecha_hora_pedido DATETIME,
calificacion VARCHAR(50),
total DECIMAL(18,2),
estado_id INT,
tiempo_estimado INT,
PRIMARY KEY(id_envio),
FOREIGN KEY(usuario_id) REFERENCES USUARIO (id_usuario),
FOREIGN KEY(localidad_id) REFERENCES LOCALIDAD (id_localidad),
FOREIGN KEY(tipo_id) REFERENCES TIPO_PAQUETE (id_tipo_paquete),
FOREIGN KEY(repartidor_id) REFERENCES REPARTIDOR (id_repartidor),
FOREIGN KEY(medio_de_pago_id) REFERENCES MEDIO_DE_PAGO (id_medio_de_pago),
FOREIGN KEY(estado_id) REFERENCES ESTADO_ENVIO (id_estado_envio)
)


CREATE TABLE RECLAMO(
id_reclamo INT NOT NULL,
usuario_id INT,
pedido_id INT,
tipo VARCHAR(50),
descr VARCHAR(50),
fecha_hora DATETIME,
operador_id INT,
estado_reclamo_id INT,
solucion VARCHAR(50),
cupon_id INT,
fecha_hora_solucion DATE,
calificacion INT

PRIMARY KEY(id_reclamo),
FOREIGN KEY(usuario_id) REFERENCES USUARIO (id_usuario),
FOREIGN KEY(pedido_id) REFERENCES PEDIDO (id_pedido),
FOREIGN KEY(operador_id) REFERENCES OPERADOR (id_operador),
FOREIGN KEY(cupon_id) REFERENCES CUPON (id_cupon)
)

CREATE TABLE CUPON_RECLAMO(
cupon_id INT NOT NULL,
reclamo_id INT NOT NULL,

PRIMARY KEY(cupon_id,reclamo_id),
FOREIGN KEY (cupon_id) REFERENCES CUPON (id_cupon),
FOREIGN KEY (reclamo_id) REFERENCES RECLAMO (id_reclamo)
)
