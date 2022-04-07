-- test4=#
-- test4=# SELECT * FROM diskquota.show_fast_schema_tablespace_quota_view ;
--  schema_name  | schema_oid | tablespace_name | tablespace_oid | quota_in_mb | nspsize_tablespace_in_bytes
-- --------------+------------+-----------------+----------------+-------------+-----------------------------
--  dummy_schema |     125010 | pg_default      |           1663 |          10 |                   163676160
--  dummy_schema |     125010 | dummy_space     |          35830 |          10 |                           0
-- (2 rows)

-- test4=#
-- test4=# SELECT diskquota.set_schema_tablespace_quota('dummy_schema', 'dummy_space', '-1');
--  set_schema_tablespace_quota
-- -----------------------------

-- (1 row)

-- test4=# SELECT * FROM diskquota.show_fast_schema_tablespace_quota_view ;
--  schema_name | schema_oid | tablespace_name | tablespace_oid | quota_in_mb | nspsize_tablespace_in_bytes
-- -------------+------------+-----------------+----------------+-------------+-----------------------------
-- (0 rows)


drop table if EXISTS spcs1.a;
drop tablespace if exists schemaspc;
drop schema if exists spcs1;

CREATE TABLESPACE schemaspc LOCATION '/tmp/schemaspc';
CREATE SCHEMA spcs1;
SET search_path TO spcs1;

CREATE TABLE a(i int) TABLESPACE schemaspc DISTRIBUTED BY (i);
INSERT INTO a SELECT generate_series(1,100);
SELECT diskquota.set_schema_tablespace_quota('spcs1', 'schemaspc','1 MB');
SELECT diskquota.wait_for_worker_new_epoch();
-- expect to fail
INSERT INTO a SELECT generate_series(1,1000000);
SELECT * FROM diskquota.show_fast_schema_tablespace_quota_view ;

SELECT diskquota.set_schema_tablespace_quota('spcs1', 'pg_default','1 MB');
SELECT diskquota.wait_for_worker_new_epoch();
SELECT * FROM diskquota.show_fast_schema_tablespace_quota_view ;

SELECT diskquota.set_schema_tablespace_quota('spcs1', 'schemaspc','-1');
SELECT diskquota.wait_for_worker_new_epoch();
SELECT * FROM diskquota.show_fast_schema_tablespace_quota_view ;

reset search_path;
drop table if EXISTS spcs1.a;
drop tablespace if exists schemaspc;
drop schema if exists spcs1;
