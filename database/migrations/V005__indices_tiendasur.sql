-- Índices elegidos tras medir la carga del laboratorio.
WHENEVER SQLERROR EXIT SQL.SQLCODE
ALTER SESSION SET CONTAINER = FREEPDB1;
CREATE UNIQUE INDEX tiendasur.ux_cli_dni ON tiendasur.cliente (dni);
CREATE INDEX tiendasur.ix_ped_cli_fec_cub ON tiendasur.pedido (id_cliente, fecha_pedido, importe, estado, id_pedido);
CREATE INDEX tiendasur.ix_ped_cp ON tiendasur.pedido (codigo_postal);
ALTER TABLE tiendasur.pedido ADD (fecha_pendiente AS (CASE WHEN estado = 'P' THEN fecha_pedido END));
CREATE INDEX tiendasur.ix_ped_pendientes ON tiendasur.pedido (fecha_pendiente);
DROP INDEX tiendasur.ix_ped_cliente;
DROP INDEX tiendasur.ix_ped_importe;
BEGIN DBMS_STATS.GATHER_SCHEMA_STATS('TIENDASUR'); END;
/
EXIT
