#!/bin/bash
### env
ALL=/home/gpadmin/gpconfigs/hostfile
SEG=/home/gpadmin/gpconfigs/hostfile_seg
CDWS=/home/gpadmin/gpconfigs/hostfile_cdw
DT=`date "+%Y-%m-%d %H:%M:%S"`
REPO=/home/gpadmin/dba/repo
#LOGFILE=/home/gpadmin/dba/gpdb6_install_result_check_`date "+%Y-%m-%d"`.log
HOSTFILE=/etc/hosts
#CDW_CNT=`cat ${HOSTFILE} | grep cdw | wc -l`
#SDW_CNT=`cat ${HOSTFILE} | grep sdw | wc -l`
CDW_CNT=`cat ${CDWS} | wc -l`
SDW_CNT=`cat ${SEG} | wc -l`
HOST_CNT=`expr \( ${CDW_CNT} \+ ${SDW_CNT} \)`
DOUBLE_CNT=`expr \( ${HOST_CNT} \+ ${HOST_CNT} \)`
BLOCKDEV_DIR=`cat /etc/fstab | grep -w dev | grep -w xfs | awk '{print $1}'`

CDW=`awk "NR==1" ${CDWS}`
if [ ${CDW_CNT} -eq 2 ]; then
SCDW=`awk "NR==2" ${CDWS}`
else
SCDW=`awk "NR==1" ${CDWS}`
fi

### make copy directory
mkdir -p /home/gpadmin/dba/repo

### gpdb install result check
echo ""
echo "=== I. Check Service and Daemon ==="

echo ""
echo "=============================="
echo "1. selinux"
ssh ${CDW} sestatus > ${REPO}/1_sestatus_cdw
ssh ${SCDW} sestatus > ${REPO}/1_sestatus_scdw
for ((i=1;i<=${SDW_CNT};i++))
do
		ssh sdw$i sestatus > ${REPO}/1_sestatus_sdw$i
	done
selinux_result=`cat ${REPO}/1_sestatus_cdw | awk '{print $3}'`
echo "$selinux_result"
if [ "$selinux_result" = disabled ]; then
	echo -e "\033[92m"[NORMAL]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!!]"\033[0m"
fi
echo ""
selinux_diff=`for ((i=1;i<=${SDW_CNT};i++))
	do
		diff -q ${REPO}/1_sestatus_cdw ${REPO}/1_sestatus_sdw$i
	done
		diff -q ${REPO}/1_sestatus_cdw ${REPO}/1_sestatus_scdw`

if [ ! -n "$selinux_diff" ]; then
	echo -e "\033[92m"[NORMAL : ALL SEGMENTS SAME]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!! : CHECK FOLLOW MESSAGE]"\033[0m"
fi
echo "$selinux_diff"

echo ""
echo "=============================="
echo "2. firewalld"
ssh ${CDW} systemctl is-active firewalld > ${REPO}/2_firewalld_active_cdw
ssh ${SCDW} systemctl is-active firewalld > ${REPO}/2_firewalld_active_scdw
for ((i=1;i<=${SDW_CNT};i++))
do
	ssh sdw$i systemctl is-active firewalld > ${REPO}/2_firewalld_active_sdw$i
	done
ssh ${CDW} systemctl is-enabled firewalld > ${REPO}/2_firewalld_enabled_cdw
ssh ${SCDW} systemctl is-enabled firewalld > ${REPO}/2_firewalld_enabled_scdw
for ((i=1;i<=${SDW_CNT};i++))
do
	ssh sdw$i systemctl is-enabled firewalld > ${REPO}/2_firewalld_enabled_sdw$i
	done
firewalld_active=`cat ${REPO}/2_firewalld_active_cdw`
firewalld_enabled=`cat ${REPO}/2_firewalld_enabled_cdw`
echo "$firewalld_active"
if [ "$firewalld_active" = unknown ]; then
	echo -e "\033[92m"[NORMAL]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!!]"\033[0m"
fi
echo ""
echo "$firewalld_enabled"
if [ "$firewalld_enabled" = disabled ]; then
	echo -e "\033[92m"[NORMAL]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!!]"\033[0m"
fi
echo ""
firewalld_diff=`for ((i=1;i<=${SDW_CNT};i++))
	do
		diff -q ${REPO}/2_firewalld_enabled_cdw ${REPO}/2_firewalld_enabled_sdw$i
	done
		diff -q ${REPO}/2_firewalld_enabled_cdw ${REPO}/2_firewalld_enabled_scdw`
if [ ! -n "$firewalld_diff" ]; then
	echo -e "\033[92m"[NORMAL : ALL SEGMENTS SAME]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!! : CHECK FOLLOW MESSAGE]"\033[0m"
fi
echo "$firewalld_diff"

echo ""
echo "=============================="
echo "3. chronyd"
ssh ${CDW} systemctl is-active chronyd > ${REPO}/3_chronyd_active_cdw
ssh ${SCDW} systemctl is-active chronyd > ${REPO}/3_chronyd_active_scdw
for ((i=1;i<=${SDW_CNT};i++))
do
	ssh sdw$i systemctl is-active chronyd > ${REPO}/3_chronyd_active_sdw$i
	done
ssh ${CDW} systemctl is-enabled chronyd > ${REPO}/3_chronyd_enabled_cdw
ssh ${SCDW} systemctl is-enabled chronyd > ${REPO}/3_chronyd_enabled_scdw
for ((i=1;i<=${SDW_CNT};i++))
do
	ssh sdw$i systemctl is-enabled chronyd> ${REPO}/3_chronyd_enabled_sdw$i
	done
chronyd_active=`cat ${REPO}/3_chronyd_active_cdw`
chronyd_enabled=`cat ${REPO}/3_chronyd_enabled_cdw`
echo "$chronyd_active"
if [ "$chronyd_active" = active ]; then
	echo -e "\033[92m"[NORMAL]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!!]"\033[0m"
fi
echo ""
echo "$chronyd_enabled"
if [ "$chronyd_enabled" = enabled ]; then
	echo -e "\033[92m"[NORMAL]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!!]"\033[0m"
fi
echo ""
chronyd_diff=`for ((i=1;i<=${SDW_CNT};i++))
	do
		diff -q ${REPO}/3_chronyd_enabled_cdw ${REPO}/3_chronyd_enabled_sdw$i
	done
		diff -q ${REPO}/3_chronyd_enabled_cdw ${REPO}/3_chronyd_enabled_scdw`
if [ ! -n "$chronyd_diff" ]; then
	echo -e "\033[92m"[NORMAL : ALL SEGMENTS SAME]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!! : CHECK FOLLOW MESSAGE]"\033[0m"
fi
echo "$chronyd_diff"

echo ""
echo "=============================="
echo "4. rc-local"
ssh ${CDW} systemctl is-active rc-local > ${REPO}/4_rc_local_active_cdw
ssh ${SCDW} systemctl is-active rc-local > ${REPO}/4_rc_local_active_scdw
for ((i=1;i<=${SDW_CNT};i++))
do
	ssh sdw$i systemctl is-active rc-local > ${REPO}/4_rc_local_active_sdw$i
	done
ssh ${CDW} systemctl is-enabled rc-local > ${REPO}/4_rc_local_enabled_cdw
ssh ${SCDW} systemctl is-enabled rc-local > ${REPO}/4_rc_local_enabled_scdw
for ((i=1;i<=${SDW_CNT};i++))
do
	ssh sdw$i systemctl is-enabled rc-local> ${REPO}/4_rc_local_enabled_sdw$i
	done
rc_local_active=`cat ${REPO}/4_rc_local_active_cdw`
rc_local_enabled=`cat ${REPO}/4_rc_local_enabled_cdw`
echo "$rc_local_active"
if [ "$rc_local_active" = active ]; then
	echo -e "\033[92m"[NORMAL]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!!]"\033[0m"
fi
echo ""
echo "$rc_local_enabled"
if [ "$rc_local_enabled" = static ]; then
	echo -e "\033[92m"[NORMAL]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!!]"\033[0m"
fi
echo ""
rc_local_diff=`for ((i=1;i<=${SDW_CNT};i++))
	do
		diff -q ${REPO}/4_rc_local_enabled_cdw ${REPO}/4_rc_local_enabled_sdw$i
	done
		diff -q ${REPO}/4_rc_local_enabled_cdw ${REPO}/4_rc_local_enabled_scdw`
if [ ! -n "$rc_local_diff" ]; then
	echo -e "\033[92m"[NORMAL : ALL SEGMENTS SAME]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!! : CHECK FOLLOW MESSAGE]"\033[0m"
fi
echo "$rc_local_diff"

#echo ""
#echo "=============================="
#echo "5. kdump"
#ssh ${CDW} systemctl is-active kdump > ${REPO}/5_kdump_active_cdw
#ssh ${SCDW} systemctl is-active kdump > ${REPO}/5_kdump_active_scdw
#for ((i=1;i<=${SDW_CNT};i++))
#do
#	ssh sdw$i systemctl is-active kdump > ${REPO}/5_kdump_active_sdw$i
#	done
#ssh ${CDW} systemctl is-enabled kdump > ${REPO}/5_kdump_enabled_cdw
#ssh ${SCDW} systemctl is-enabled kdump > ${REPO}/5_kdump_enabled_scdw
#for ((i=1;i<=${SDW_CNT};i++))
#do
#	ssh sdw$i systemctl is-enabled kdump> ${REPO}/5_kdump_enabled_sdw$i
#	done
#kdump_active=`cat ${REPO}/5_kdump_active_cdw`
#kdump_enabled=`cat ${REPO}/5_kdump_enabled_cdw`
#echo "$kdump_active"
#if [ "$kdump_active" = active ]; then
#	echo -e "\033[92m"[NORMAL]"\033[0m"
#else
#	echo -e "\033[91m"[WARNING!!!]"\033[0m"
#fi
#echo ""
#echo "$kdump_enabled"
#if [ "$kdump_enabled" = enabled ]; then
#	echo -e "\033[92m"[NORMAL]"\033[0m"
#else
#	echo -e "\033[91m"[WARNING!!!]"\033[0m"
#fi
#echo ""
#kdump_diff=`for ((i=1;i<=${SDW_CNT};i++))
#	do
#		diff -q ${REPO}/5_kdump_enabled_cdw ${REPO}/5_kdump_enabled_sdw$i
#	done
#		diff -q ${REPO}/5_kdump_enabled_cdw ${REPO}/5_kdump_enabled_scdw`
#if [ ! -n "$kdump_diff" ]; then
#	echo -e "\033[92m"[NORMAL : ALL SEGMENTS SAME]"\033[0m"
#else
#	echo -e "\033[91m"[WARNING!!! : CHECK FOLLOW MESSAGE]"\033[0m"
#fi
#echo "$kdump_diff"

echo ""
echo ""
echo "=== II. Check OS Configurations ==="

echo ""
echo "=============================="
echo "11. hostname"
ssh ${CDW} scp /etc/hostname ${CDW}:${REPO}/11_hostname_cdw
ssh ${SCDW} scp /etc/hostname ${CDW}:${REPO}/11_hostname_scdw
for ((i=1;i<=${SDW_CNT};i++))
do
		ssh sdw$i scp /etc/hostname ${CDW}:${REPO}/11_hostname_sdw$i
	done
hostname_result=`cat ${REPO}/11_hostname_*`
echo "$hostname_result"
if [ ! -z "$hostname_result" ]; then
	echo -e "\033[92m"[ORDER IS AS FOLLOWS : cdw, sdw, scdw]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!! : SOME SEG IS NOT SET]"\033[0m"
fi
echo "$hostname_result"

echo ""
echo "=============================="
echo "12. /etc/hosts"
ssh ${CDW} scp /etc/hosts ${CDW}:${REPO}/12_hosts_cdw
ssh ${SCDW} scp /etc/hosts ${CDW}:${REPO}/12_hosts_scdw
for ((i=1;i<=${SDW_CNT};i++))
do
		ssh sdw$i scp /etc/hosts ${CDW}:${REPO}/12_hosts_sdw$i
	done
hosts_result=`cat ${REPO}/12_hosts_cdw`
echo "$hosts_result"
echo ""
hosts_diff=`for ((i=1;i<=${SDW_CNT};i++))
	do
		diff -q ${REPO}/12_hosts_cdw ${REPO}/12_hosts_sdw$i
	done
		diff -q ${REPO}/12_hosts_cdw ${REPO}/12_hosts_scdw`
if [ ! -n "$hosts_diff" ]; then
	echo -e "\033[92m"[NORMAL : ALL SEGMENTS SAME]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!! : CHECK FOLLOW MESSAGE]"\033[0m"
fi
echo "$hosts_diff"

echo ""
echo "=============================="
echo "13. redhat release version"
ssh ${CDW} scp /etc/redhat-release ${CDW}:${REPO}/13_redhat_release_cdw
ssh ${SCDW} scp /etc/redhat-release ${CDW}:${REPO}/13_redhat_release_scdw
for ((i=1;i<=${SDW_CNT};i++))
do
		ssh sdw$i scp /etc/redhat-release ${CDW}:${REPO}/13_redhat_release_sdw$i
	done
release_result=`cat ${REPO}/13_redhat_release_cdw`
echo "$release_result"
echo ""
release_diff=`for ((i=1;i<=${SDW_CNT};i++))
	do
		diff -q ${REPO}/13_redhat_release_cdw ${REPO}/13_redhat_release_sdw$i
	done
		diff -q ${REPO}/13_redhat_release_cdw ${REPO}/13_redhat_release_scdw`
if [ ! -n "$release_diff" ]; then
	echo -e "\033[92m"[NORMAL : ALL SEGMENTS SAME]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!! : CHECK FOLLOW MESSAGE]"\033[0m"
fi
echo "$release_diff"

echo ""
echo "=============================="
echo "14. kernel"
ssh ${CDW} uname -r > ${REPO}/14_kernel_cdw
ssh ${SCDW} uname -r > ${REPO}/14_kernel_scdw
for ((i=1;i<=${SDW_CNT};i++))
do
		ssh sdw$i uname -r > ${REPO}/14_kernel_sdw$i
	done
kernel_result=`cat ${REPO}/14_kernel_cdw`
echo "$kernel_result"
echo ""
kernel_diff=`for ((i=1;i<=${SDW_CNT};i++))
	do
		diff -q ${REPO}/14_kernel_cdw ${REPO}/14_kernel_sdw$i
	done
		diff -q ${REPO}/14_kernel_cdw ${REPO}/14_kernel_scdw`
if [ ! -n "$kernel_diff" ]; then
	echo -e "\033[92m"[NORMAL : ALL SEGMENTS SAME]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!! : CHECK FOLLOW MESSAGE]"\033[0m"
fi
echo "$kernel_diff"

echo ""
echo "=============================="
echo "15. mtu"
ssh ${CDW} ifconfig | grep mtu > ${REPO}/15_mtu_cdw
ssh ${SCDW} ifconfig | grep mtu > ${REPO}/15_mtu_scdw
for ((i=1;i<=${SDW_CNT};i++))
do
		ssh sdw$i ifconfig | grep mtu > ${REPO}/15_mtu_sdw$i
	done
mtu_result=`cat ${REPO}/15_mtu_cdw`
echo "$mtu_result"
echo ""
mtu_diff=`for ((i=1;i<=${SDW_CNT};i++))
	do
		diff -q ${REPO}/15_mtu_cdw ${REPO}/15_mtu_sdw$i
	done
		diff -q ${REPO}/15_mtu_cdw ${REPO}/15_mtu_scdw`
if [ ! -n "$mtu_diff" ]; then
	echo -e "\033[92m"[NORMAL : ALL SEGMENTS SAME]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!! : CHECK FOLLOW MESSAGE]"\033[0m"
fi
echo "$mtu_diff"

echo ""
echo "=============================="
echo "16. df (file usage)"
ssh ${CDW} df -h | grep data > ${REPO}/16_df_cdw
ssh ${SCDW} df -h | grep data > ${REPO}/16_df_scdw
for ((i=1;i<=${SDW_CNT};i++))
do
		ssh sdw$i df -h | grep data > ${REPO}/16_df_sdw$i
	done
df_result=`cat ${REPO}/16_df_*`
echo "$df_result"
echo ""
if [ ! -z "$df_result" ]; then
	echo -e "\033[92m"[ORDER IS AS FOLLOWS : cdw, sdw, scdw]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!! : SOME SEG IS NOT SET]"\033[0m"
fi
echo "$df_result"

echo ""
echo "=============================="
echo "17. fstab (filesystem)"
ssh ${CDW} cat /etc/fstab | grep data > ${REPO}/17_fstab_cdw
ssh ${SCDW} cat /etc/fstab | grep data > ${REPO}/17_fstab_scdw
for ((i=1;i<=${SDW_CNT};i++))
do
		ssh sdw$i cat /etc/fstab | grep data > ${REPO}/17_fstab_sdw$i
	done
fstab_result=`cat ${REPO}/17_fstab_*`
echo "$fstab_result"
echo ""
if [ ! -z "$fstab_result" ]; then
	echo -e "\033[92m"[ORDER IS AS FOLLOWS : cdw, sdw, scdw]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!! : SOME SEG IS NOT SET]"\033[0m"
fi
echo "$fstab_result"

echo ""
echo "=============================="
echo "18. resolv conf"
ssh ${CDW} scp /etc/resolv.conf ${CDW}:${REPO}/18_resolvconf_cdw
ssh ${SCDW} scp /etc/resolv.conf ${CDW}:${REPO}/18_resolvconf_scdw
for ((i=1;i<=${SDW_CNT};i++))
do
		ssh sdw$i scp /etc/resolv.conf ${CDW}:${REPO}/18_resolvconf_sdw$i
	done
resolvconf_result=`cat ${REPO}/18_resolvconf_cdw`
echo "$resolvconf_result"
echo ""
resolvconf_diff=`for ((i=1;i<=${SDW_CNT};i++))
	do
		diff -q ${REPO}/18_resolvconf_cdw ${REPO}/18_resolvconf_sdw$i
	done
		diff -q ${REPO}/18_resolvconf_cdw ${REPO}/18_resolvconf_scdw`
if [ ! -n "$resolvconf_diff" ]; then
	echo -e "\033[92m"[NORMAL : ALL SEGMENTS SAME]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!! : CHECK FOLLOW MESSAGE]"\033[0m"
fi
echo "$resolvconf_diff"

echo ""
echo ""
echo "=== III. Check GPDB Configurations ==="

echo ""
echo "=============================="
echo "21. sysctl conf"
ssh ${CDW} scp /etc/sysctl.conf ${CDW}:${REPO}/21_sysctlconf_cdw
ssh ${SCDW} scp /etc/sysctl.conf ${CDW}:${REPO}/21_sysctlconf_scdw
for ((i=1;i<=${SDW_CNT};i++))
do
		ssh sdw$i scp /etc/sysctl.conf ${CDW}:${REPO}/21_sysctlconf_sdw$i
	done
sysctlconf_result=`cat ${REPO}/21_sysctlconf_cdw`
echo "$sysctlconf_result"
echo ""
sysctlconf_diff=`for ((i=1;i<=${SDW_CNT};i++))
	do
		diff -q ${REPO}/21_sysctlconf_cdw ${REPO}/21_sysctlconf_sdw$i
	done
		diff -q ${REPO}/21_sysctlconf_cdw ${REPO}/21_sysctlconf_scdw`
if [ ! -n "$sysctlconf_diff" ]; then
	echo -e "\033[92m"[NORMAL : ALL SEGMENTS SAME]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!! : CHECK FOLLOW MESSAGE]"\033[0m"
fi
echo "$sysctlconf_diff"

echo ""
echo "=============================="
echo "22. grubby"
ssh ${CDW} grubby --info=ALL | grep elevator | grep hugepage > ${REPO}/22_grubby_cdw
ssh ${SCDW} grubby --info=ALL | grep elevator | grep hugepage > ${REPO}/22_grubby_scdw
for ((i=1;i<=${SDW_CNT};i++))
do
		ssh sdw$i grubby --info=ALL | grep elevator | grep hugepage > ${REPO}/22_grubby_sdw$i
	done
###grubby_result=`cat ${REPO}/22_grubby_* | wc -l`
###echo "$grubby_result"
###echo ""
###if [ ! -n "$grubby_result" -eq "${DOUBLE_CNT}" ]; then
###	echo -e "\033[92m"[NORMAL : ALL SEGMENTS SAME]"\033[0m"
###else
###	echo -e "\033[91m"[WARNING!!! : SOME SEG IS NOT SET]"\033[0m"
###fi
###echo "$grubby_diff"
grubby_result=`cat ${REPO}/22_grubby_cdw`
echo "$grubby_result"
echo ""
grubby_diff=`for ((i=1;i<=${SDW_CNT};i++))
        do
                diff -q ${REPO}/22_grubby_cdw ${REPO}/22_grubby_sdw$i
        done
                diff -q ${REPO}/22_grubby_cdw ${REPO}/22_grubby_scdw`
if [ ! -n "$grubby_diff" ]; then
        echo -e "\033[92m"[NORMAL : ALL SEGMENTS SAME]"\033[0m"
else
        echo -e "\033[91m"[WARNING!!! : CHECK FOLLOW MESSAGE]"\033[0m"
fi
echo "$grubby_diff"

echo ""
echo "=============================="
echo "23. ulimit"
ssh ${CDW} scp /etc/security/limits.conf ${CDW}:${REPO}/23_ulimit_cdw
ssh ${SCDW} scp /etc/security/limits.conf ${CDW}:${REPO}/23_ulimit_scdw
for ((i=1;i<=${SDW_CNT};i++))
do
		ssh sdw$i scp /etc/security/limits.conf ${CDW}:${REPO}/23_ulimit_sdw$i
	done
ulimit_result=`cat ${REPO}/23_ulimit_cdw`
echo "$ulimit_result"
echo ""
ulimit_diff=`for ((i=1;i<=${SDW_CNT};i++))
	do
		diff -q ${REPO}/23_ulimit_cdw ${REPO}/23_ulimit_sdw$i
	done
		diff -q ${REPO}/23_ulimit_cdw ${REPO}/23_ulimit_scdw`
if [ ! -n "$ulimit_diff" ]; then
	echo -e "\033[92m"[NORMAL : ALL SEGMENTS SAME]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!! : CHECK FOLLOW MESSAGE]"\033[0m"
fi
echo "$ulimit_diff"

echo ""
echo "=============================="
echo "24. blockdev"
ssh ${CDW} /sbin/blockdev --getra ${BLOCKDEV_DIR} > ${REPO}/24_blockdev_cdw
ssh ${SCDW} /sbin/blockdev --getra ${BLOCKDEV_DIR} > ${REPO}/24_blockdev_scdw
for ((i=1;i<=${SDW_CNT};i++))
do
		ssh sdw$i /sbin/blockdev --getra ${BLOCKDEV_DIR} > ${REPO}/24_blockdev_sdw$i
	done
blockdev_result=`cat ${REPO}/24_blockdev_cdw`
echo "$blockdev_result"
echo ""
blockdev_diff=`for ((i=1;i<=${SDW_CNT};i++))
	do
		diff -q ${REPO}/24_blockdev_cdw ${REPO}/24_blockdev_sdw$i
	done
		diff -q ${REPO}/24_blockdev_cdw ${REPO}/24_blockdev_scdw`
if [ ! -n "$blockdev_diff" ]; then
	echo -e "\033[92m"[NORMAL : ALL SEGMENTS SAME]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!! : CHECK FOLLOW MESSAGE]"\033[0m"
fi
echo "$blockdev_diff"

echo ""
echo "=============================="
echo "25. logind conf"
ssh ${CDW} scp /etc/systemd/logind.conf ${CDW}:${REPO}/25_logindconf_cdw
ssh ${SCDW} scp /etc/systemd/logind.conf ${CDW}:${REPO}/25_logindconf_scdw
for ((i=1;i<=${SDW_CNT};i++))
do
		ssh sdw$i scp /etc/systemd/logind.conf ${CDW}:${REPO}/25_logindconf_sdw$i
	done
logindconf_result=`cat ${REPO}/25_logindconf_cdw | grep IPC`
echo "$logindconf_result"
echo ""
logindconf_diff=`for ((i=1;i<=${SDW_CNT};i++))
	do
		diff -q ${REPO}/25_logindconf_cdw ${REPO}/25_logindconf_sdw$i
	done
		diff -q ${REPO}/25_logindconf_cdw ${REPO}/25_logindconf_scdw`
if [ ! -n "$logindconf_diff" ]; then
	echo -e "\033[92m"[NORMAL : ALL SEGMENTS SAME]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!! : CHECK FOLLOW MESSAGE]"\033[0m"
fi
echo "$logindconf_diff"

echo ""
echo "=============================="
echo "26. sshd config"
ssh ${CDW} scp /etc/ssh/sshd_config ${CDW}:${REPO}/26_sshdconfig_cdw
ssh ${SCDW} scp /etc/ssh/sshd_config ${CDW}:${REPO}/26_sshdconfig_scdw
for ((i=1;i<=${SDW_CNT};i++))
do
		ssh sdw$i scp /etc/ssh/sshd_config ${CDW}:${REPO}/26_sshdconfig_sdw$i
	done
sshdconfig_result=`cat ${REPO}/26_sshdconfig_cdw | egrep "MaxStartups|UseDNS"`
echo "$sshdconfig_result"
echo ""
sshdconfig_diff=`for ((i=1;i<=${SDW_CNT};i++))
	do
		diff -q ${REPO}/26_sshdconfig_cdw ${REPO}/26_sshdconfig_sdw$i
	done
		diff -q ${REPO}/26_sshdconfig_cdw ${REPO}/26_sshdconfig_scdw`
if [ ! -n "$sshdconfig_diff" ]; then
	echo -e "\033[92m"[NORMAL : ALL SEGMENTS SAME]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!! : CHECK FOLLOW MESSAGE]"\033[0m"
fi
echo "$sshdconfig_diff"

#echo ""
#echo "=============================="
#echo "27. yum"
#ssh ${CDW} yum repolist > ${REPO}/27_yum_cdw
#ssh ${SCDW} yum repolist > ${REPO}/27_yum_scdw
#for ((i=1;i<=${SDW_CNT};i++))
#do
#		ssh sdw$i yum repolist > ${REPO}/27_yum_sdw$i
#	done
#yum_result=`cat ${REPO}/27_yum_cdw`
#echo "$yum_result"
#echo ""
#yum_diff=`for ((i=1;i<=${SDW_CNT};i++))
#	do
#		diff -q ${REPO}/27_yum_cdw ${REPO}/27_yum_sdw$i
#	done
#		diff -q ${REPO}/27_yum_cdw ${REPO}/27_yum_scdw`
#if [ ! -n "$yum_diff" ]; then
#	echo -e "\033[92m"[NORMAL : ALL SEGMENTS SAME]"\033[0m"
#else
#	echo -e "\033[91m"[WARNING!!! : CHECK FOLLOW MESSAGE]"\033[0m"
#fi
#echo "$yum_diff"
