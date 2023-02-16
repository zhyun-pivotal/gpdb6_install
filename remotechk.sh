#!/bin/bash
source /home/gpadmin/.bash_profile
source /usr/local/greenplum-db/greenplum_path.sh

## For remote monitor v1.1
## set env variable
HOSTFILE=/home/gpadmin/remotechk/hostfile
SDWCNT=`cat ${HOSTFILE} | grep sdw | wc -l`
MDWCNT=`cat ${HOSTFILE} | grep mdw | wc -l`
DT=`date "+%Y-%m-%d %H:%M:%S"`
REPO=/home/gpadmin/remotechk/repo
LOGFILE=~/gpdb_install_check`date +"%Y-%m-%d"`.log
HOSTCNT=`expr \( $MDWCNT \+ $SDWCNT \)`
DOUBLECNT=`expr \( $HOSTCNT \+ $HOSTCNT \)`
GPCCWEBCHK=`ls -dl --time-style=locale /usr/local/greenplum-cc* | grep -v ">" | awk '{print $9}' | cut -d "-" -f 3 | head -n 1`
GPCCVER=`ls -al --time-style=locale /usr/local/greenplum-cc-web | awk '{print $11}' | cut -d "-" -f 4 | cut -d "." -f 1`
SMDWCHK=`psql -Atc "select count(*) from gp_segment_configuration where content='-1' and role='m';"`
HOSTALIAS=`cat /etc/hosts | grep $HOSTNAME | awk '{print $3}'`
PXFDIR=`ls -al --time-style=locale /usr/local | grep pxf-gp6 | awk '{print $9}'`

## mkdir repo
mkdir -p /home/gpadmin/remotechk/repo

## make hostfile
if [ -z "${HOSTALIAS}" ]; then
	echo "============================================================"
	echo "ERROR : You have to add alias names in the /etc/hosts file on all nodes!"
	echo "============================================================"
	exit
else
	cat /etc/hosts | egrep 'mdw|sdw' | grep -v "#" | awk '{print $3}' > /home/gpadmin/remotechk/hostfile
fi

echo ""
echo "============================================================"
echo "Greenplum Health Check"
echo "============================================================"
echo ""

echo " 1. uptime"
echo "$(ssh mdw hostname) $(ssh mdw uptime | awk '{print $3,$4}')" > ${REPO}/1_uptime_mdw
if [ ${SMDWCHK} -eq 1 ] && [ `cat /etc/hosts | grep smdw | wc -l` -eq 1 ]; then
	echo "$(ssh smdw hostname) $(ssh smdw uptime | awk '{print $3,$4}')" > ${REPO}/1_uptime_smdw
fi
for ((i=1;i<=$SDWCNT;i++))
	do
		echo "$(ssh sdw$i hostname) $(ssh sdw$i uptime | awk '{print $3,$4}')" > ${REPO}/1_uptime_sdw$i
	done
uptime_result=`cat ${REPO}/1_uptime*`
echo "$uptime_result"
if [ ! -z "$uptime_result" ]; then
	echo -e "\033[92m"[ORDER IS AS FOLLOWS: mdw, sdw, smdw]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!: SOME SEG IS DOWN]"\033[0m"
fi

echo "============================================================"
echo ""

echo " 2. pxf status"
if [ -n "${PXFDIR}" ]; then
	/usr/local/pxf-gp6/bin/pxf cluster status > ${REPO}/2_pxf_mdw
else
	/usr/local/greenplum-db/pxf/bin/pxf cluster status > ${REPO}/2_pxf_mdw ## previous pxf v5.x
fi
pxf_result=`cat ${REPO}/2_pxf_mdw`
echo "$pxf_result"

echo "============================================================"
echo ""

echo " 3. gpcc stsatus"
if [ "${GPCCWEBCHK}" != "web" ]; then
	/usr/local/greenplum-cc/bin/gpcc status > ${REPO}/3_gpcc_mdw
else
	if [ ${GPCCVER} -le 3 ]; then
		/usr/local/greenplum-cc-web/bin/gpcmdr --status > ${REPO}/3_gpcc_mdw
	elif [ ${GPCCVER} -ge 4 ]; then
		/usr/local/greenplum-cc-web/bin/gpcc status > ${REPO}/3_gpcc_mdw
	else
		echo "GPCC not installed"
	fi
fi
gpcc_result=`cat ${REPO}/3_gpcc_mdw`
echo "$gpcc_result"

echo "============================================================"
echo ""

echo " 4. check downed primary"
psql -ec "select * from gp_segment_configuration where preferred_role='p' and status='d';" > ${REPO}/4_check_down_primary_mdw
check_down_primary_result=`cat ${REPO}/4_check_down_primary_mdw`
echo "$check_down_primary_result"

echo "============================================================"
echo ""

echo " 5. check downed mirror"
psql -ec "select * from gp_segment_configuration where preferred_role='m' and status='d';" > ${REPO}/5_check_down_mirror_mdw
check_down_mirror_result=`cat ${REPO}/5_check_down_mirror_mdw`
echo "$check_down_mirror_result"

echo "============================================================"
echo ""

echo " 6. check downed time"
psql -ec "select * from gp_configuration_history order by time desc limit 10;" > ${REPO}/6_check_down_time_mdw
check_down_time_result=`cat ${REPO}/6_check_down_time_mdw`
echo "$check_down_time_result"

echo "============================================================"
echo ""

echo " 7. check service"
psql -ec "select count(*) from dba.service_monitoring;" > ${REPO}/7_check_service_mdw
check_service_result=`cat ${REPO}/7_check_service_mdw`
echo "$check_service_result"

echo "============================================================"
echo ""

echo " 8. count session process"
echo "$(ssh mdw hostname) $(ssh mdw ps -ef | grep postgres | grep -v grep | grep con | wc -l)" > ${REPO}/8_count_session_mdw
if [ ${SMDWCHK} -eq 1 ] && [ `cat /etc/hosts | grep smdw | wc -l` -eq 1 ]; then
	echo "$(ssh smdw hostname) $(ssh smdw ps -ef | grep postgres | grep -v grep | grep con | wc -l)" > ${REPO}/8_count_session_smdw
fi
for ((i=1;i<=$SDWCNT;i++))
	do
		echo "$(ssh sdw$i hostname) $(ssh sdw$i ps -ef | grep postgres | grep -v grep | grep con | wc -l)" > ${REPO}/8_count_session_sdw$i
	done
count_session_result=`cat ${REPO}/8_count_session*`
echo "$count_session_result"
if [ ! -z "$count_session_result" ]; then
	echo -e "\033[92m"[ORDER IS AS FOLLOWS: mdw, sdw, smdw]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!: SOME SEG IS DOWN]"\033[0m"
fi

echo "============================================================"
echo ""

echo " 9. check VIP"
VIP=`ls -al /usr/local/bin | grep vip_env.sh | wc -l`
echo "(step1) VIP configure check..."
if [[ ${VIP} -ge 1 ]]; then
	echo ">> VIP is configured"
	echo " "
	echo "(step2) VIP service check..."
	VIPIF=`cat /usr/local/bin/vip_env.sh | grep VIP_INTERFACE | cut -d '=' -f 2`
	VIP2=`ip addr | grep ${VIPIF} | wc -l`
	echo ">>" `ip addr | grep ${VIPIF}`
	if [[ ${VIP2} -ge 1 ]]; then
		echo ">> [NORMAL] : VIP is running..."
	else
		echo ">> [WARNING!!] : VIP service disabled"
	fi
else
	echo ">> VIP is not configured"
fi

echo ""