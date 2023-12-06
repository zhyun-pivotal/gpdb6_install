#!/bin/bash
mkdir -p /home/gpadmin/dba/diaglog
export LOGFILE=/home/gpadmin/dba/diaglog/diag_gpdb.$(date '+%Y%m%d_%H%M')
export HOSTFILESEG=/home/gpadmin/gpconfigs/hostfile_seg

echo "" > ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 1. GPDB Parameter" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
gpssh -h mdw 'grep -v ^$ /data/master/gpseg-1/postgresql.conf | grep -v "#"' >> ${LOGFILE}
echo "" >> ${LOGFILE}
gpssh -h smdw 'grep -v ^$ /data/master/gpseg-1/postgresql.conf | grep -v "#"' >> ${LOGFILE}
echo "" >> ${LOGFILE}
gpssh -f ${HOSTFILESEG} 'grep -v ^$ /data*/primary/gpseg*/postgresql.conf | grep -v "#"' >> ${LOGFILE}
echo "" >> ${LOGFILE}
gpssh -h mdw 'gpconfig -s gp_vmem_protect_limit' >> ${LOGFILE}
gpssh -h mdw 'gpconfig -s gp_workfile_compression' >> ${LOGFILE}
gpssh -h mdw 'gpconfig -s max_connections' >> ${LOGFILE}
gpssh -h mdw 'gpconfig -s gp_resource_manager' >> ${LOGFILE}
gpssh -h mdw 'gpconfig -s gp_segment_connect_timeout' >> ${LOGFILE}
gpssh -h mdw 'gpconfig -s gp_fts_probe_timeout' >> ${LOGFILE}
gpssh -h mdw 'gpconfig -s log_duration' >> ${LOGFILE}
gpssh -h mdw 'gpconfig -s log_min_duration_statement' >> ${LOGFILE}

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 2. Instance config" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -c "SELECT * FROM gp_segment_configuration order by 2,1;" >> ${LOGFILE}

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 3. GPDB Version" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
gpstate --version >> ${LOGFILE}
gpcc --version >> ${LOGFILE}
pxf --version >> ${LOGFILE}
