-- Banco de pruebas del laboratorio de índices.
WHENEVER SQLERROR EXIT SQL.SQLCODE
ALTER SESSION SET CONTAINER = FREEPDB1;
CREATE BIGFILE TABLESPACE tbs_tiendasur DATAFILE 'tiendasur01.dbf' SIZE 100M AUTOEXTEND ON NEXT 50M;
CREATE USER tiendasur NO AUTHENTICATION DEFAULT TABLESPACE tbs_tiendasur QUOTA UNLIMITED ON tbs_tiendasur;
CREATE TABLE tiendasur.cliente (id_cliente NUMBER NOT NULL, CONSTRAINT pk_cliente PRIMARY KEY (id_cliente));
INSERT INTO tiendasur.cliente SELECT LEVEL FROM dual CONNECT BY LEVEL <= 100000;
CREATE TABLE tiendasur.pedido (
  id_pedido NUMBER NOT NULL,
  id_cliente NUMBER NOT NULL,
  importe NUMBER(10,2) NOT NULL,
  CONSTRAINT pk_pedido PRIMARY KEY (id_pedido),
  CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente) REFERENCES tiendasur.cliente (id_cliente)
);
INSERT INTO tiendasur.pedido
SELECT LEVEL, MOD(LEVEL - 1, 100000) + 1, MOD(LEVEL, 10000) / 100
FROM dual CONNECT BY LEVEL <= 1000000;
COMMIT;
CREATE INDEX tiendasur.ix_ped_cliente ON tiendasur.pedido (id_cliente);
BEGIN
  DBMS_STATS.GATHER_SCHEMA_STATS('TIENDASUR');
END;
/
EXIT
