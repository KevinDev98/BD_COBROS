CREATE DATABASE COBRANZA_FULL
ON PRIMARY
(
NAME=COBRANZA_FULL_DATA,
FILENAME='C:\BD\MSSQLS COBRANZA FULL\COBRANZA_FULL_DATA.mdf',
SIZE=60MB,
MAXSIZE=1024MB,
FILEGROWTH=10%
)
LOG ON
(
NAME=COBRANZA_FULL_LOG,
FILENAME='C:\BD\MSSQLS COBRANZA FULL\COBRANZA_FULL_LOG.ldf',
SIZE=60MB,
MAXSIZE=600MB,
FILEGROWTH=10%
)
USE COBRANZA_FULL

CREATE TABLE CAT_PUESTOS(
    ID_PUESTO SMALLINT IDENTITY(1,1),
    NOMBRE_PUESTO VARCHAR(35) NOT NULL UNIQUE,
    ESTATUS BIT DEFAULT 1,
    CONSTRAINT PK_CP PRIMARY KEY (ID_PUESTO)
)

CREATE TABLE CAT_TIPOS_PAGO(
    ID_TIPO_PAGO SMALLINT IDENTITY(1,1),
    TIPO_PAGO CHAR(25) UNIQUE,
    ESTATUS BIT DEFAULT 1,
    CONSTRAINT PK_TP PRIMARY KEY(ID_TIPO_PAGO)
)

CREATE TABLE CAT_LUGARES_PAGO(
    ID_LUGARES_PAGO SMALLINT IDENTITY(1,1),
    LUGAR_PAGO CHAR(15) NOT NULL UNIQUE,
    ESTATUS BIT DEFAULT 1,
    CONSTRAINT PK_LP PRIMARY KEY(ID_LUGARES_PAGO)
)

CREATE TABLE CAT_BANCOS_PAGO(
    ID_BANK_PAGO SMALLINT IDENTITY(1,1),
    NUMERO_CUENTA VARCHAR(20) NOT NULL,
    BANCO CHAR(25) NOT NULL UNIQUE,
    ESTATUS BIT DEFAULT 1,
    CONSTRAINT PK_BP PRIMARY KEY(ID_BANK_PAGO),
    CONSTRAINT CH_NR CHECK (ISNUMERIC(NUMERO_CUENTA)=1)
)

CREATE TABLE CAT_NUM_PAGOS(
    ID_NUM_PAGOS SMALLINT IDENTITY(1,1),
    NUM_PAGOS SMALLINT NOT NULL,
    PORCENT_INT DECIMAL(9,5) NOT NULL,
    DIAS_TOLERANCIA SMALLINT NOT NULL,
    ESTATUS BIT DEFAULT 1,
    CONSTRAINT PK_NP PRIMARY KEY(ID_NUM_PAGOS),
    CONSTRAINT CH_NP CHECK(NUM_PAGOS IN(1,3,6,9,12,15,18,24,30,36,48))
)

CREATE TABLE CODIGOS_ACCION(
    ID_COD_AC CHAR(4),
    DESC_ACCION VARCHAR(50) NOT NULL,
    ESTATUS BIT DEFAULT 1,
    CONSTRAINT PR_CA PRIMARY KEY (ID_COD_AC),
    CONSTRAINT CH_CA CHECK(ID_COD_AC LIKE '[A-Z][A-Z][A-Z][A-Z]')
)

CREATE TABLE CODIGOS_RES(
    ID_COD_RES CHAR(4),
    DESC_RES VARCHAR(50) NOT NULL,
    ESTATUS BIT DEFAULT 1,
    CONSTRAINT PR_CR PRIMARY KEY (ID_COD_RES),
    CONSTRAINT CH_CR CHECK(ID_COD_RES LIKE '[A-Z][A-Z][A-Z][A-Z]')
)

CREATE TABLE REL_CODIGOS(
    FK_ID_COD_AC CHAR(4),
    FK_ID_COD_RES CHAR(4),
    CONSTRAINT FK_CA FOREIGN KEY (FK_ID_COD_AC) REFERENCES CODIGOS_ACCION(ID_COD_AC),
    CONSTRAINT FK_CR FOREIGN KEY (FK_ID_COD_RES) REFERENCES CODIGOS_RES(ID_COD_RES)
)

CREATE TABLE GESTORES(
    ID_GESTOR SMALLINT IDENTITY(1,1),
    NOMBRE_FULL VARCHAR(70) NOT NULL,
    USERNAME CHAR(15) NOT NULL UNIQUE,
    FECHA_INGRESO DATETIME DEFAULT GETDATE(),
    ESTATUS BIT DEFAULT 1,
    FK_PUESTO SMALLINT,
    CONSTRAINT PK_GES PRIMARY KEY(ID_GESTOR),
    CONSTRAINT FK_PUESTO FOREIGN KEY(FK_PUESTO)REFERENCES CAT_PUESTOS(ID_PUESTO)
)

CREATE TABLE DATOS_PERS_CLIENTES(
    NUMERO_CUENTA VARCHAR(50) DEFAULT CONCAT(4,REPLACE(CONVERT(VARCHAR(100), RAND()),'0.',''),FORMAT(GETDATE(),'ddMMyyyyhhmmss')),
    FECHA_REGISTRO DATETIME DEFAULT GETDATE(),
    FECHA_ALTA DATE NOT NULL,
    NOMBRE_COMPLETO VARCHAR(150) NOT NULL,
    CURP VARCHAR(20) NOT NULL,
    RFC VARCHAR(15) NOT NULL,
    ESTADO VARCHAR(30) NOT NULL,
    MUNICIPIO VARCHAR(35) NOT NULL,
    CP CHAR(5) NOT NULL,
    DIRECCION VARCHAR(150) NOT NULL,
    TELEFONO VARCHAR(15) NOT NULL,
    FK_GESTOR_ALTA SMALLINT,
    CONSTRAINT PK_NC PRIMARY KEY(NUMERO_CUENTA),
    CONSTRAINT FK_GA FOREIGN KEY(FK_GESTOR_ALTA) REFERENCES GESTORES(ID_GESTOR),
    CONSTRAINT CH_CP CHECK(ISNUMERIC(CP)=1)
)

CREATE TABLE DATOS_ADEUDO_CLIENTES(
    ID_ADEUDO_CLIENTE UNIQUEIDENTIFIER DEFAULT NEWID(),
    MONTO_ADEUDO_INICIAL DECIMAL(9,2),
    MONTO_ADEUDO_ACTUAL DECIMAL(9,2),
    MONTO_ATRASO DECIMAL(9,2),
    MONTO_MIN_PAGO DECIMAL(9,2),
    MONTO_A_PAGAR DECIMAL(9,2),
    DIAS_ATRASO SMALLINT,
    PORCENT_INTE_DIA DECIMAL(9,5),
    MONTO_INTE_ANTERIOR DECIMAL(9,2),
    MONTO_INTE_ACTUAL DECIMAL(9,2),
    DIAS_TOLERANCIA SMALLINT,
    DIA_PAGO_MES SMALLINT,
    FECHA_MAX_PAGO DATE,
    ESTATUS BIT DEFAULT 1,
    FK_NUMERO_CUENTA VARCHAR(50),
    FK_NUM_PAGOS SMALLINT,
    CONSTRAINT PK_IAC PRIMARY KEY(ID_ADEUDO_CLIENTE),
    CONSTRAINT FK_NCC FOREIGN KEY(FK_NUMERO_CUENTA) REFERENCES DATOS_PERS_CLIENTES(NUMERO_CUENTA),
    CONSTRAINT FK_NPC FOREIGN KEY(FK_NUM_PAGOS) REFERENCES CAT_NUM_PAGOS(ID_NUM_PAGOS),
    CONSTRAINT CH_DPM CHECK(DIA_PAGO_MES BETWEEN 1 AND 31),
    CONSTRAINT CH_DT CHECK(DIAS_TOLERANCIA BETWEEN 1 AND 7),
    CONSTRAINT CH_MONTOS CHECK(MONTO_ADEUDO_INICIAL>0.0 AND MONTO_MIN_PAGO>0.0)
)

CREATE TABLE GESTIONES(
    ID_GESTION SMALLINT IDENTITY(1,1),
    FECHA_REGISTRO DATETIME DEFAULT GETDATE(),
    FECHA_GESTION DATETIME NOT NULL,
    COMENTARIO VARCHAR(1000) NOT NULL,
    FK_NUM_CUENTA VARCHAR(50),
    FK_GESTOR_GEST SMALLINT,
    FK_COD_AC CHAR(4),
    FK_COD_RES CHAR(4),
    CONSTRAINT PK_IDG PRIMARY KEY(ID_GESTION),
    CONSTRAINT FK_NCG FOREIGN KEY(FK_NUM_CUENTA)REFERENCES DATOS_PERS_CLIENTES(NUMERO_CUENTA),
    CONSTRAINT FK_IGG FOREIGN KEY(FK_GESTOR_GEST) REFERENCES GESTORES(ID_GESTOR),
    CONSTRAINT FK_CAG FOREIGN KEY(FK_COD_AC) REFERENCES CODIGOS_ACCION(ID_COD_AC),
    CONSTRAINT FK_CRG FOREIGN KEY(FK_COD_RES) REFERENCES CODIGOS_RES(ID_COD_RES)
)

CREATE TABLE HISTORICO_PAGOS(
    ID_PAGO VARCHAR(50) DEFAULT CONCAT(4,REPLACE(CONVERT(VARCHAR(100), RAND()),'0.',''),FORMAT(GETDATE(),'ddMMyyyyhhmmss')),
    FECHA_REGISTRO DATETIME DEFAULT GETDATE(),
    FECHA_PAGO DATETIME NOT NULL,
    MONTO_PAGADO DECIMAL(9,2) NOT NULL,
    CUENTA_BANK_CLIENT VARCHAR(20),
    NUM_REF_PAGO VARCHAR(25) UNIQUE,
    ESTATUS BIT DEFAULT 1,
    FK_NUMERO_CTA_CLIENT VARCHAR(50),
    FK_TIPO_PAGO SMALLINT,
    FK_LUGAR_PAGO SMALLINT,
    FK_BANCO_PAGO SMALLINT,
    CONSTRAINT PK_IDP PRIMARY KEY(ID_PAGO),
    CONSTRAINT FK_NCCP FOREIGN KEY(FK_NUMERO_CTA_CLIENT) REFERENCES DATOS_PERS_CLIENTES(NUMERO_CUENTA),
    CONSTRAINT FK_TPHP FOREIGN KEY(FK_TIPO_PAGO) REFERENCES CAT_TIPOS_PAGO(ID_TIPO_PAGO),
    CONSTRAINT FK_LPHP FOREIGN KEY(FK_LUGAR_PAGO) REFERENCES CAT_LUGARES_PAGO(ID_LUGARES_PAGO),
    CONSTRAINT FK_BP FOREIGN KEY(FK_BANCO_PAGO) REFERENCES CAT_BANCOS_PAGO(ID_BANK_PAGO),
    CONSTRAINT CH_NRP CHECK(ISNUMERIC(NUM_REF_PAGO)=1),
    CONSTRAINT CH_MP CHECK(MONTO_PAGADO>0.00)
)
