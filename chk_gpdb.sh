#!/bin/bash
mkdir -p /home/gpadmin/dba/chklog
export LOGFILE=/home/gpadmin/dba/chklog/chk_gpdb.$(date '+%Y%m%d_%H%M')
export HOSTFILESEG=/home/gpadmin/gpconfigs/hostfile_seg

echo "" > $LOGFILE
echo "####################" >> $LOGFILE
echo "### 1. GPDB Parameter" >> $LOGFILE
echo "####################" >> $LOGFILE
gpssh -h mdw 'cat /data/master/gpseg-1/postgresql.conf | grep -v "#" | grep -v ^$' >> $LOGFILE
echo "" >> $LOGFILE
gpssh -h smdw 'cat /data/master/gpseg-1/postgresql.conf | grep -v "#" | grep -v ^$' >> $LOGFILE
echo "" >> $LOGFILE
gpssh -f $HOSTFILESEG 'cat /data/primary/gpseg*/postgresql.conf | grep -v "#" | grep -v ^$' >> $LOGFILE

echo "" >> $LOGFILE
echo "####################" >> $LOGFILE
echo "### 2. Instance config" >> $LOGFILE
echo "####################" >> $LOGFILE
psql -c "SELECT * FROM gp_segment_configuration order by 2,1;" >> $LOGFILE

echo "" >> $LOGFILE
echo "####################" >> $LOGFILE
echo "### 3. GPDB Version" >> $LOGFILE
echo "####################" >> $LOGFILE
gpstate --version >> $LOGFILE
gpcc --version >> $LOGFILE
pxf --version >> $LOGFILE
