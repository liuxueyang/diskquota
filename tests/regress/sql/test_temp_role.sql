-- Test temp table restrained by role id
CREATE SCHEMA strole;
CREATE ROLE u3temp NOLOGIN;
SET search_path TO strole;

SELECT diskquota.set_role_quota('u3temp', '1MB');
CREATE TABLE a(i int) DISTRIBUTED BY (i);
ALTER TABLE a OWNER TO u3temp;
CREATE TEMP TABLE ta(i int);
ALTER TABLE ta OWNER TO u3temp;

-- expected failed: fill temp table
INSERT INTO ta SELECT generate_series(1,100000);
SELECT diskquota.wait_for_worker_new_epoch();
-- expected failed: 
INSERT INTO a SELECT generate_series(1,100);
DROP TABLE ta;
SELECT diskquota.wait_for_worker_new_epoch();
INSERT INTO a SELECT generate_series(1,100);

DROP TABLE a;
DROP ROLE u3temp;
RESET search_path;
DROP SCHEMA strole;
