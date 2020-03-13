#!/bin/bash

source /usr/local/greenplum-db/greenplum_path.sh
source /home/gpadmin/.bash_profile

GPDBVER=`psql -AXtc "select * from version();" | awk '{print $5}' | cut -d "." -f 1`
GPCCVER=`ls -al /usr/local/greenplum-cc-web | awk '{print $11}' | cut -d "-" -f 4 | cut -d "." -f 1`

echo "1. hostname"
hostname

echo ""
echo "2. date"
gpssh -f /home/gpadmin/gpconfigs/hostfile_gpchk date

echo ""
echo "3. ntpd"
gpssh -f /home/gpadmin/gpconfigs/hostfile_gpchk "/sbin/service ntpd status | egrep -i 'active|ntpd \(|is '"

echo ""
echo "4. gpstate"
/usr/local/greenplum-db/bin/gpstate

echo ""
echo "5. gpcc"
if [ ${GPCCVER} -le 3 ]; then
  /usr/local/greenplum-cc-web/bin/gpcmdr --status
elif [ ${GPCCVER} -ge 4 ]; then
 /usr/local/greenplum-cc-web/bin/gpcc status
else
 echo "GPCC not installed"
fi

echo ""
echo "6. pxf"
/usr/local/greenplum-db/pxf/bin/pxf cluster status

echo ""
echo "7. session"
if [ ${GPDBVER} -eq 6 ]; then
  psql -c "select waiting_reason, now()-query_start as running_time, rsgname, usename, client_addr, waiting, pid, sess_id, state from pg_stat_activity where state <> 'idle' and pid <> pg_backend_pid() order by 6,2 desc;"
else
  psql -c "select now()-query_start, datname, usename, client_addr, waiting, procpid, sess_id  from pg_stat_activity where current_query not like '%IDLE%' order by 5,1 desc;"
fi

echo ""
echo "8. lock table"
if [ ${GPDBVER} -eq 6 ]; then
  psql -c "select distinct w.locktype, w.relation::regclass as relation , w.mode, w.pid as waiting_pid, other.pid as running_pid from pg_catalog.pg_locks as w join pg_catalog.pg_stat_activity as w_stm on (w_stm.pid = w.pid) join pg_catalog.pg_locks as other on ((w.database = other.database and w.relation = other.relation) or w.transactionid = other.transactionid) join pg_catalog.pg_stat_activity as other_stm on (other_stm.pid = other.pid) where not w.granted and w.pid <> other.pid;"
else
  psql -c "select distinct w.locktype, w.relation::regclass as relation , w.mode, w.pid as waiting_pid, other.pid as running_pid from pg_catalog.pg_locks as w join pg_catalog.pg_stat_activity as w_stm on (w_stm.procpid = w.pid) join pg_catalog.pg_locks as other on ((w.database = other.database and w.relation = other.relation) or w.transactionid = other.transactionid) join pg_catalog.pg_stat_activity as other_stm on (other_stm.procpid = other.pid) where not w.granted and w.pid <> other.pid;"
fi

echo ""
echo "9. date usage"
gpssh -f /home/gpadmin/gpconfigs/hostfile_gpchk df -h | grep data

echo ""
echo "10. db size"
psql -c "select coalesce(datname, 'total') as database_name, sum(round(pg_database_size(datname)/1024.0/1024/1024, 1)) as db_size_gb from pg_database group by rollup(datname);"

echo ""
echo "11. db age"
psql -c " 
WITH cluster AS (
    SELECT gp_segment_id, datname, age(datfrozenxid) age FROM pg_database
    UNION ALL
    SELECT gp_segment_id, datname, age(datfrozenxid) age FROM gp_dist_random('pg_database')
)
SELECT  gp_segment_id
, datname
, age
, ((2^31-1 - current_setting('xid_stop_limit')::int - current_setting('xid_warn_limit')::int)) as current_warn_age
, ((2^31-1 - current_setting('xid_stop_limit')::int)) as current_stop_age
,   CASE
        WHEN age < (2^31-1 - current_setting('xid_stop_limit')::int - current_setting('xid_warn_limit')::int) * 0.7 THEN 'BELOW WARN LIMIT'
        WHEN ((2^31-1 - current_setting('xid_stop_limit')::int - current_setting('xid_warn_limit')::int) * 0.7 < age) AND (age < (2^31-1 - current_setting('xid_stop_limit')::int - current_setting('xid_warn_limit')::int)) THEN 'NEEDED VACUUM FREEZE and BELOW WARN LIMIT'
        WHEN  ((2^31-1 - current_setting('xid_stop_limit')::int - current_setting('xid_warn_limit')::int) < age) AND (age <  (2^31-1 - current_setting('xid_stop_limit')::int)) THEN 'OVER WARN LIMIT and UNDER STOP LIMIT'
        WHEN age > (2^31-1 - current_setting('xid_stop_limit')::int ) THEN 'OVER STOP LIMIT'
        WHEN age < 0 THEN 'OVER WRAPAROUND'
    END
FROM cluster
ORDER BY datname, gp_segment_id
Limit 10;"
