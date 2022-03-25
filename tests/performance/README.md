To execute the whole test:

```
# Clear system disk cache with root permission
sync; echo 3 > /proc/sys/vm/drop_caches
dropdb testdb
createdb testdb
./test.sh testdb diskquota_disabled.txt

dropdb testdb
createdb testdb
psql -c "CREATE EXTENSION diskquota" testdb
psql -c "CREATE EXTENSION diskquota" testdb
psql -c "SELECT diskquota.set_schema_quota('public', '1000 GB')"
sync; echo 3 > /proc/sys/vm/drop_caches
./test.sh testdb diskquota_enabled.txt
```

To generate the report:

```
./make_report.py diskquota_disabled.txt diskquota_enabled.txt > report.csv
```
