#!/bin/bash
mkdir -p /home/gpadmin/dba/diaglog
export LOGFILE=/home/gpadmin/dba/diaglog/chkconf_gpdb.$(date '+%Y%m%d_%H%M')
export HOSTFILE=/home/gpadmin/gpconfigs/hostfile_all

GPMAJOR=`gpstate --version | awk '{print $3}' | awk -F'.' '{print $1}'`
GPMINOR=`gpstate --version | awk '{print $3}' | awk -F'.' '{print $2}'`

echo "" > ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 1. GPDB version" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
gpstate --version >> ${LOGFILE}

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 2. GPCC version" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
gpcc --version >> ${LOGFILE}

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 3. PXF version" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
if [ ${GPMAJOR} -eq 6 ] && [ ${GPMINOR} -le 18 ]
then
	/usr/local/greenplum-db/pxf/bin/pxf --version >> ${LOGFILE}
elif [ ${GPMAJOR} -eq 6 ] && [ ${GPMINOR} -gt 18 ]
then
	/usr/local/pxf-gp6/bin/pxf --version >> ${LOGFILE}
else
	echo "Please check the PXF version manually" >> ${LOGFILE}
fi

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 4. gppkg list" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
gppkg -q --all >> ${LOGFILE}

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 5. Mirror config check" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -c "select * from gp_segment_configuration order by 2,1;" >> ${LOGFILE}

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 6. Install directory check" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'ls -al /usr/local/' >> ${LOGFILE}