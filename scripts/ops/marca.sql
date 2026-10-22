-- scripts/ops/marca.sql — define &marca con la misma marca de tiempo UTC que $(ts) de los scripts de shell
SET TERMOUT OFF
COLUMN marca NEW_VALUE marca NOPRINT
SELECT TO_CHAR(SYSTIMESTAMP AT TIME ZONE 'UTC', 'YYYYMMDD"T"HH24MISS"Z"') AS marca FROM dual;
SET TERMOUT ON
