--USE COBRANZA_FULL;

--#DROP TABLE IF exists CAT_PUESTOS;
CREATE TABLE CAT_PUESTOS(
    ID_PUESTO SMALLINT GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),
    NOMBRE_PUESTO VARCHAR2(35) NOT NULL UNIQUE,
    ESTATUS SMALLINT DEFAULT 1,
    CONSTRAINT CH_ST CHECK(ESTATUS BETWEEN 0 AND 1),
    CONSTRAINT PK_CP PRIMARY KEY (ID_PUESTO)
);

CREATE TABLE CAT_TIPOS_PAGO(
    ID_TIPO_PAGO SMALLINT GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),
    TIPO_PAGO CHAR(25) UNIQUE,
    ESTATUS SMALLINT DEFAULT 1,
    CONSTRAINT CH_ST1 CHECK(ESTATUS BETWEEN 0 AND 1),
    CONSTRAINT PK_TP PRIMARY KEY(ID_TIPO_PAGO)
);

CREATE TABLE CAT_LUGARES_PAGO(
    ID_LUGARES_PAGO SMALLINT GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),
    LUGAR_PAGO CHAR(15) NOT NULL UNIQUE,
    ESTATUS SMALLINT DEFAULT 1,
    CONSTRAINT CH_ST2 CHECK(ESTATUS BETWEEN 0 AND 1),
    CONSTRAINT PK_LP PRIMARY KEY(ID_LUGARES_PAGO)
);

CREATE TABLE CAT_BANCOS_PAGO(
    ID_BANK_PAGO SMALLINT GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),
    NUMERO_CUENTA VARCHAR2(20) NOT NULL,
    BANCO CHAR(25) NOT NULL UNIQUE,
    ESTATUS SMALLINT DEFAULT 1,
    CONSTRAINT CH_ST3 CHECK(ESTATUS BETWEEN 0 AND 1),
    CONSTRAINT PK_BP PRIMARY KEY(ID_BANK_PAGO)
);

CREATE TABLE CAT_NUM_PAGOS(
    ID_NUM_PAGOS SMALLINT GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),
    NUM_PAGOS SMALLINT NOT NULL,
    PORCENT_INT DECIMAL(9,5) NOT NULL,
    DIAS_TOLERANCIA SMALLINT NOT NULL,
    ESTATUS SMALLINT DEFAULT 1,
    CONSTRAINT CH_ST4 CHECK(ESTATUS BETWEEN 0 AND 1),
    CONSTRAINT PK_NP PRIMARY KEY(ID_NUM_PAGOS),
    CONSTRAINT CH_NP CHECK(NUM_PAGOS IN(1,3,6,9,12,15,18,24,30,36,48))
);

CREATE TABLE CODIGOS_ACCION(
    ID_COD_AC CHAR(4),
    DESC_ACCION VARCHAR2(50) NOT NULL,
    ESTATUS SMALLINT DEFAULT 1,
    CONSTRAINT CH_ST5 CHECK(ESTATUS BETWEEN 0 AND 1),
    CONSTRAINT PR_CA PRIMARY KEY (ID_COD_AC),
    CONSTRAINT CH_CA CHECK(ID_COD_AC LIKE '[A-Z][A-Z][A-Z][A-Z]')
);

CREATE TABLE CODIGOS_RES(
    ID_COD_RES CHAR(4),
    DESC_RES VARCHAR2(50) NOT NULL,
    ESTATUS SMALLINT DEFAULT 1,
    CONSTRAINT CH_ST6 CHECK(ESTATUS BETWEEN 0 AND 1),
    CONSTRAINT PR_CR PRIMARY KEY (ID_COD_RES),
    CONSTRAINT CH_CR CHECK(ID_COD_RES LIKE '[A-Z][A-Z][A-Z][A-Z]') ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE REL_CODIGOS(
    FK_ID_COD_AC CHAR(4),
    FK_ID_COD_RES CHAR(4),
    CONSTRAINT FK_CA FOREIGN KEY (FK_ID_COD_AC) REFERENCES CODIGOS_ACCION(ID_COD_AC) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT FK_CR FOREIGN KEY (FK_ID_COD_RES) REFERENCES CODIGOS_RES(ID_COD_RES) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE GESTORES(
    ID_GESTOR SMALLINT GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),
    NOMBRE_FULL VARCHAR2(70) NOT NULL,
    USERNAME CHAR(15) NOT NULL UNIQUE,
    FECHA_INGRESO DATE DEFAULT SYSDATE,
    ESTATUS SMALLINT DEFAULT 1,
    CONSTRAINT CH_ST7 CHECK(ESTATUS BETWEEN 0 AND 1),
    FK_PUESTO SMALLINT,
    CONSTRAINT PK_GES PRIMARY KEY(ID_GESTOR),
    CONSTRAINT FK_PUESTO FOREIGN KEY(FK_PUESTO)REFERENCES CAT_PUESTOS(ID_PUESTO) ON DELETE NO ACTION ON UPDATE CASCADE
);

/*SELECT concat(( REPLACE(REPLACE(REPLACE(SYSDATE,'-',''),':',''),' ','') ),replace(convert(rand(), char(50)),'0.',''));
SELECT ( REPLACE(REPLACE(REPLACE(SYSDATE,'-',''),':',''),' ','') );*/
CREATE TABLE DATOS_PERS_CLIENTES(
    NUMERO_CUENTA VARCHAR2(50) ,
    FECHA_REGISTRO DATE DEFAULT SYSDATE,
    FECHA_ALTA DATE NOT NULL,
    NOMBRE_COMPLETO VARCHAR2(150) NOT NULL,
    CURP VARCHAR2(20) NOT NULL,
    RFC VARCHAR2(15) NOT NULL,
    ESTADO VARCHAR2(30) NOT NULL,
    MUNICIPIO VARCHAR2(35) NOT NULL,
    CP CHAR(5) NOT NULL,
    DIRECCION VARCHAR2(150) NOT NULL,
    TELEFONO VARCHAR2(15) NOT NULL,
    FK_GESTOR_ALTA SMALLINT,
    CONSTRAINT PK_NC PRIMARY KEY(NUMERO_CUENTA),
    CONSTRAINT FK_GA FOREIGN KEY(FK_GESTOR_ALTA) REFERENCES GESTORES(ID_GESTOR) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE DATOS_ADEUDO_CLIENTES(
    ID_ADEUDO_CLIENTE VARCHAR2(50) ,
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
    ESTATUS SMALLINT DEFAULT 1,
    CONSTRAINT CH_ST8 CHECK(ESTATUS BETWEEN 0 AND 1),
    FK_NUMERO_CUENTA VARCHAR2(50),
    FK_NUM_PAGOS SMALLINT,
    CONSTRAINT PK_IAC PRIMARY KEY(ID_ADEUDO_CLIENTE),
    CONSTRAINT FK_NCC FOREIGN KEY(FK_NUMERO_CUENTA) REFERENCES DATOS_PERS_CLIENTES(NUMERO_CUENTA) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT FK_NPC FOREIGN KEY(FK_NUM_PAGOS) REFERENCES CAT_NUM_PAGOS(ID_NUM_PAGOS) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT CH_DPM CHECK(DIA_PAGO_MES BETWEEN 1 AND 31),
    CONSTRAINT CH_DT CHECK(DIAS_TOLERANCIA BETWEEN 1 AND 7),
    CONSTRAINT CH_MONTOS CHECK(MONTO_ADEUDO_INICIAL>0.0 AND MONTO_MIN_PAGO>0.0)
);

CREATE TABLE GESTIONES(
    ID_GESTION SMALLINT GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),
    FECHA_REGISTRO DATE DEFAULT SYSDATE,
    FECHA_GESTION DATE NOT NULL,
    COMENTARIO VARCHAR2(1000) NOT NULL,
    FK_NUM_CUENTA VARCHAR2(60),
    FK_GESTOR_GEST SMALLINT,
    FK_COD_AC CHAR(4),
    FK_COD_RES CHAR(4),
    CONSTRAINT PK_IDG PRIMARY KEY(ID_GESTION),
    CONSTRAINT FK_NCG FOREIGN KEY(FK_NUM_CUENTA)REFERENCES DATOS_PERS_CLIENTES(NUMERO_CUENTA) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT FK_IGG FOREIGN KEY(FK_GESTOR_GEST) REFERENCES GESTORES(ID_GESTOR) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT FK_CAG FOREIGN KEY(FK_COD_AC) REFERENCES CODIGOS_ACCION(ID_COD_AC) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT FK_CRG FOREIGN KEY(FK_COD_RES) REFERENCES CODIGOS_RES(ID_COD_RES) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE HISTORICO_PAGOS(
    ID_PAGO VARCHAR2(50) ,
    FECHA_REGISTRO DATE DEFAULT SYSDATE,
    FECHA_PAGO DATE NOT NULL,
    MONTO_PAGADO DECIMAL(9,2) NOT NULL,
    CUENTA_BANK_CLIENT VARCHAR2(20),
    NUM_REF_PAGO VARCHAR2(25) UNIQUE,
    ESTATUS SMALLINT DEFAULT 1,
    CONSTRAINT CH_ST9 CHECK(ESTATUS BETWEEN 0 AND 1),
    FK_NUMERO_CTA_CLIENT VARCHAR2(50),
    FK_TIPO_PAGO SMALLINT,
    FK_LUGAR_PAGO SMALLINT,
    FK_BANCO_PAGO SMALLINT,
    CONSTRAINT PK_IDP PRIMARY KEY(ID_PAGO),
    CONSTRAINT FK_NCCP FOREIGN KEY(FK_NUMERO_CTA_CLIENT) REFERENCES DATOS_PERS_CLIENTES(NUMERO_CUENTA) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT FK_TPHP FOREIGN KEY(FK_TIPO_PAGO) REFERENCES CAT_TIPOS_PAGO(ID_TIPO_PAGO) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT FK_LPHP FOREIGN KEY(FK_LUGAR_PAGO) REFERENCES CAT_LUGARES_PAGO(ID_LUGARES_PAGO) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT FK_BP FOREIGN KEY(FK_BANCO_PAGO) REFERENCES CAT_BANCOS_PAGO(ID_BANK_PAGO) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT CH_MP CHECK(MONTO_PAGADO>0.00)
);

--SELECT (( REPLACE(REPLACE(REPLACE(SYSDATE,'/',''),':',''),' ','') )||'-'|| REPLACE(dbms_random.value(1, 9),'.','') ) FROM DUAL;
