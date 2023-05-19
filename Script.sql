CREATE TABLE LOCALIDAD(
id_localidad INT NOT NULL,
nombre VARCHAR(40)

PRIMARY KEY (id_localidad)
)


CREATE TABLE DIRECCION_USUARIO(
id_direccion_usuario INT NOT NULL,
localidad INT,

FOREIGN KEY (localidad) REFERENCES LOCALIDAD (id_localidad),
PRIMARY KEY (id_direccion_usuario)
)

CREATE TABLE USUARIO(
id_usuario INT NOT NULL,
nombre VARCHAR(50),
apellido VARCHAR(50),
dni INT,
direccion_usuario int,
fecha_nac DATE,
fecha_registro DATE,
telefono VARCHAR(30),
mail VARCHAR(50),

FOREIGN KEY (direccion_usuario) REFERENCES DIRECCION_USUARIO (id_direccion_usuario),
PRIMARY KEY (id_usuario)
)


