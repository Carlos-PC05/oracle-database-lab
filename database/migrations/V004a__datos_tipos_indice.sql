-- Completa el banco V004 con las columnas usadas en los ejercicios de índices.
WHENEVER SQLERROR EXIT SQL.SQLCODE
ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER TABLE tiendasur.cliente ADD (dni VARCHAR2(9), email VARCHAR2(100), nombre VARCHAR2(50), apellidos VARCHAR2(100), telefono VARCHAR2(20), pais VARCHAR2(2), ciudad VARCHAR2(50), fecha_alta DATE);
UPDATE tiendasur.cliente SET dni = LPAD(id_cliente, 8, '0') || SUBSTR('TRWAGMYFPDXBNJZSQVHLCKE', MOD(id_cliente, 23) + 1, 1),
  email = 'cliente' || id_cliente || '@tiendasur.es', nombre = 'Cliente', apellidos = 'Apellido' || id_cliente,
  telefono = TO_CHAR(600000000 + id_cliente), pais = CASE WHEN MOD(id_cliente, 40) = 0 THEN 'FR' ELSE 'ES' END,
  ciudad = CASE WHEN MOD(id_cliente, 100) = 0 THEN 'Lorca' ELSE 'Murcia' END, fecha_alta = TRUNC(SYSDATE) - MOD(id_cliente, 2000);
CREATE INDEX tiendasur.ix_cli_pais_ciudad ON tiendasur.cliente (pais, ciudad);
ALTER TABLE tiendasur.pedido ADD (fecha_pedido TIMESTAMP, estado VARCHAR2(1), canal VARCHAR2(1), codigo_postal VARCHAR2(5));
UPDATE tiendasur.pedido SET fecha_pedido = TRUNC(SYSDATE) - CASE WHEN id_pedido <= 400000 THEN MOD(id_pedido, 365) ELSE 365 + MOD(id_pedido, 1000) END,
  estado = CASE WHEN MOD(id_pedido, 50) = 0 THEN 'P' ELSE 'E' END,
  canal = 'W', codigo_postal = TO_CHAR  (25000 + MOD(id_pedido, 11000));
COMMIT;
CREATE INDEX tiendasur.ix_ped_fecha ON tiendasur.pedido (fecha_pedido);
CREATE INDEX tiendasur.ix_ped_importe ON tiendasur.pedido (importe);
BEGIN DBMS_STATS.GATHER_SCHEMA_STATS('TIENDASUR'); END;
/
EXIT
