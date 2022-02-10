-- Test default tablespace
-- start_ignore
\! mkdir -p /tmp/custom_tablespace
-- end_ignore

DROP TABLE if EXISTS t;
SELECT diskquota.set_role_tablespace_quota(CURRENT_ROLE, 'pg_default', '1 MB');
CREATE TABLE t (i int);
SELECT diskquota.wait_for_worker_new_epoch();
-- expect insert to fail
INSERT INTO t SELECT generate_series(1, 1000000);
DROP TABLE IF EXISTS t;

-- database in customized tablespace with hard limits on
CREATE TABLESPACE custom_tablespace LOCATION '/tmp/custom_tablespace';
CREATE DATABASE db_with_tablespace TABLESPACE custom_tablespace;
\c db_with_tablespace;
CREATE EXTENSION diskquota;
SELECT diskquota.enable_hardlimit();

SELECT diskquota.set_role_tablespace_quota(CURRENT_ROLE, 'custom_tablespace', '1MB');
SELECT diskquota.wait_for_worker_new_epoch();
-- expect create table to fail
CREATE TABLE t_in_custom_tablespace AS SELECT generate_series(1, 1000000);

-- expect create table to succeed
SELECT diskquota.wait_for_worker_new_epoch();
CREATE TABLE t_in_custom_tablespace AS SELECT generate_series(1, 100);
-- expect insert records to fail
INSERT INTO t_in_custom_tablespace SELECT generate_series(1, 1000000);

-- clean up
DROP EXTENSION diskquota;
DROP TABLE IF EXISTS t_in_custom_tablespace;
\c postgres;
DROP DATABASE IF EXISTS db_with_tablespace;
DROP TABLESPACE IF EXISTS custom_tablespace;
\! rm -rf /tmp/custom_tablespace
