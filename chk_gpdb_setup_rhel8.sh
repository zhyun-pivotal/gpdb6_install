#!/bin/bash
### env
ALL=/home/gpadmin/gpconfigs/hostfile
SEG=/home/gpadmin/gpconfigs/hostfile_seg
MDWS=/home/gpadmin/gpconfigs/hostfile_mdw
DT=`date "+%Y-%m-%d %H:%M:%S"`
REPO=/home/gpadmin/dba/repo
#LOGFILE=/home/gpadmin/dba/gpdb6_install_result_check_`date "+%Y-%m-%d"`.log
HOSTFILE=/etc/hosts
#MDW_CNT=`cat ${HOSTFILE} | grep mdw | wc -l`
#SDW_CNT=`cat ${HOSTFILE} | grep sdw | wc -l`
MDW_CNT=`cat ${MDWS} | wc -l`
SDW_CNT=`cat ${SEG} | wc -l`
HOST_CNT=`expr \( ${MDW_CNT} \+ ${SDW_CNT} \)`
DOUBLE_CNT=`expr \( ${HOST_CNT} \+ ${HOST_CNT} \)`
BLOCKDEV_DIR=`cat /etc/fstab | grep data | awk '{print$1}'`

MDW=`awk "NR==1" ${MDWS}`
if [ ${MDW_CNT} -eq 2 ]; then
SMDW=`awk "NR==2" ${MDWS}`
else
SMDW=`awk "NR==1" ${MDWS}`
fi

### make copy directory
mkdir -p /home/gpadmin/dba/repo

### gpdb install result check
echo ""
echo "=== I. Check Service and Daemon ==="

echo ""
echo "=============================="
echo "1. selinux"
ssh ${MDW} sestatus > ${REPO}/1_sestatus_mdw
ssh ${SMDW} sestatus > ${REPO}/1_sestatus_smdw
for ((i=1;i<=${SDW_CNT};i++))
do
		ssh sdw$i sestatus > ${REPO}/1_sestatus_sdw$i
	done
selinux_result=`cat ${REPO}/1_sestatus_mdw | awk '{print $3}'`
echo "$selinux_result"
if [ "$selinux_result" = disabled ]; then
	echo -e "\033[92m"[NORMAL]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!!]"\033[0m"
fi
echo ""
selinux_diff=`for ((i=1;i<=${SDW_CNT};i++))
	do
		diff -q ${REPO}/1_sestatus_mdw ${REPO}/1_sestatus_sdw$i
	done
		diff -q ${REPO}/1_sestatus_mdw ${REPO}/1_sestatus_smdw`

if [ ! -n "$selinux_diff" ]; then
	echo -e "\033[92m"[NORMAL : ALL SEGMENTS SAME]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!! : CHECK FOLLOW MESSAGE]"\033[0m"
fi
echo "$selinux_diff"

echo ""
echo "=============================="
echo "2. firewalld"
ssh ${MDW} systemctl is-active firewalld > ${REPO}/2_firewalld_active_mdw
ssh ${SMDW} systemctl is-active firewalld > ${REPO}/2_firewalld_active_smdw
for ((i=1;i<=${SDW_CNT};i++))
do
	ssh sdw$i systemctl is-active firewalld > ${REPO}/2_firewalld_active_sdw$i
	done
ssh ${MDW} systemctl is-enabled firewalld > ${REPO}/2_firewalld_enabled_mdw
ssh ${SMDW} systemctl is-enabled firewalld > ${REPO}/2_firewalld_enabled_smdw
for ((i=1;i<=${SDW_CNT};i++))
do
	ssh sdw$i systemctl is-enabled firewalld > ${REPO}/2_firewalld_enabled_sdw$i
	done
firewalld_active=`cat ${REPO}/2_firewalld_active_mdw`
firewalld_enabled=`cat ${REPO}/2_firewalld_enabled_mdw`
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
		diff -q ${REPO}/2_firewalld_enabled_mdw ${REPO}/2_firewalld_enabled_sdw$i
	done
		diff -q ${REPO}/2_firewalld_enabled_mdw ${REPO}/2_firewalld_enabled_smdw`
if [ ! -n "$firewalld_diff" ]; then
	echo -e "\033[92m"[NORMAL : ALL SEGMENTS SAME]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!! : CHECK FOLLOW MESSAGE]"\033[0m"
fi
echo "$firewalld_diff"

echo ""
echo "=============================="
echo "3. ntpd"
ssh ${MDW} systemctl is-active ntpd > ${REPO}/3_ntpd_active_mdw
ssh ${SMDW} systemctl is-active ntpd > ${REPO}/3_ntpd_active_smdw
for ((i=1;i<=${SDW_CNT};i++))
do
	ssh sdw$i systemctl is-active ntpd > ${REPO}/3_ntpd_active_sdw$i
	done
ssh ${MDW} systemctl is-enabled ntpd > ${REPO}/3_ntpd_enabled_mdw
ssh ${SMDW} systemctl is-enabled ntpd > ${REPO}/3_ntpd_enabled_smdw
for ((i=1;i<=${SDW_CNT};i++))
do
	ssh sdw$i systemctl is-enabled ntpd> ${REPO}/3_ntpd_enabled_sdw$i
	done
ntpd_active=`cat ${REPO}/3_ntpd_active_mdw`
ntpd_enabled=`cat ${REPO}/3_ntpd_enabled_mdw`
echo "$ntpd_active"
if [ "$ntpd_active" = active ]; then
	echo -e "\033[92m"[NORMAL]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!!]"\033[0m"
fi
echo ""
echo "$ntpd_enabled"
if [ "$ntpd_enabled" = enabled ]; then
	echo -e "\033[92m"[NORMAL]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!!]"\033[0m"
fi
echo ""
ntpd_diff=`for ((i=1;i<=${SDW_CNT};i++))
	do
		diff -q ${REPO}/3_ntpd_enabled_mdw ${REPO}/3_ntpd_enabled_sdw$i
	done
		diff -q ${REPO}/3_ntpd_enabled_mdw ${REPO}/3_ntpd_enabled_smdw`
if [ ! -n "$ntpd_diff" ]; then
	echo -e "\033[92m"[NORMAL : ALL SEGMENTS SAME]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!! : CHECK FOLLOW MESSAGE]"\033[0m"
fi
echo "$ntpd_diff"

echo ""
echo "=============================="
echo "4. rc-local"
ssh ${MDW} systemctl is-active rc-local > ${REPO}/4_rc_local_active_mdw
ssh ${SMDW} systemctl is-active rc-local > ${REPO}/4_rc_local_active_smdw
for ((i=1;i<=${SDW_CNT};i++))
do
	ssh sdw$i systemctl is-active rc-local > ${REPO}/4_rc_local_active_sdw$i
	done
ssh ${MDW} systemctl is-enabled rc-local > ${REPO}/4_rc_local_enabled_mdw
ssh ${SMDW} systemctl is-enabled rc-local > ${REPO}/4_rc_local_enabled_smdw
for ((i=1;i<=${SDW_CNT};i++))
do
	ssh sdw$i systemctl is-enabled rc-local> ${REPO}/4_rc_local_enabled_sdw$i
	done
rc_local_active=`cat ${REPO}/4_rc_local_active_mdw`
rc_local_enabled=`cat ${REPO}/4_rc_local_enabled_mdw`
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
		diff -q ${REPO}/4_rc_local_enabled_mdw ${REPO}/4_rc_local_enabled_sdw$i
	done
		diff -q ${REPO}/4_rc_local_enabled_mdw ${REPO}/4_rc_local_enabled_smdw`
if [ ! -n "$rc_local_diff" ]; then
	echo -e "\033[92m"[NORMAL : ALL SEGMENTS SAME]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!! : CHECK FOLLOW MESSAGE]"\033[0m"
fi
echo "$rc_local_diff"

echo ""
echo ""
echo "=== II. Check OS Configurations ==="

echo ""
echo "=============================="
echo "11. hostname"
ssh ${MDW} scp /etc/hostname ${MDW}:${REPO}/11_hostname_mdw
ssh ${SMDW} scp /etc/hostname ${MDW}:${REPO}/11_hostname_smdw
for ((i=1;i<=${SDW_CNT};i++))
do
		ssh sdw$i scp /etc/hostname ${MDW}:${REPO}/11_hostname_sdw$i
	done
hostname_result=`cat ${REPO}/11_hostname_*`
echo "$hostname_result"
if [ ! -z "$hostname_result" ]; then
	echo -e "\033[92m"[ORDER IS AS FOLLOWS : mdw, sdw, smdw]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!! : SOME SEG IS NOT SET]"\033[0m"
fi
echo "$hostname_result"

echo ""
echo "=============================="
echo "12. /etc/hosts"
ssh ${MDW} scp /etc/hosts ${MDW}:${REPO}/12_hosts_mdw
ssh ${SMDW} scp /etc/hosts ${MDW}:${REPO}/12_hosts_smdw
for ((i=1;i<=${SDW_CNT};i++))
do
		ssh sdw$i scp /etc/hosts ${MDW}:${REPO}/12_hosts_sdw$i
	done
hosts_result=`cat ${REPO}/12_hosts_mdw`
echo "$hosts_result"
echo ""
hosts_diff=`for ((i=1;i<=${SDW_CNT};i++))
	do
		diff -q ${REPO}/12_hosts_mdw ${REPO}/12_hosts_sdw$i
	done
		diff -q ${REPO}/12_hosts_mdw ${REPO}/12_hosts_smdw`
if [ ! -n "$hosts_diff" ]; then
	echo -e "\033[92m"[NORMAL : ALL SEGMENTS SAME]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!! : CHECK FOLLOW MESSAGE]"\033[0m"
fi
echo "$hosts_diff"

echo ""
echo "=============================="
echo "13. redhat release version"
ssh ${MDW} scp /etc/redhat-release ${MDW}:${REPO}/13_redhat_release_mdw
ssh ${SMDW} scp /etc/redhat-release ${MDW}:${REPO}/13_redhat_release_smdw
for ((i=1;i<=${SDW_CNT};i++))
do
		ssh sdw$i scp /etc/redhat-release ${MDW}:${REPO}/13_redhat_release_sdw$i
	done
release_result=`cat ${REPO}/13_redhat_release_mdw`
echo "$release_result"
echo ""
release_diff=`for ((i=1;i<=${SDW_CNT};i++))
	do
		diff -q ${REPO}/13_redhat_release_mdw ${REPO}/13_redhat_release_sdw$i
	done
		diff -q ${REPO}/13_redhat_release_mdw ${REPO}/13_redhat_release_smdw`
if [ ! -n "$release_diff" ]; then
	echo -e "\033[92m"[NORMAL : ALL SEGMENTS SAME]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!! : CHECK FOLLOW MESSAGE]"\033[0m"
fi
echo "$release_diff"

echo ""
echo "=============================="
echo "14. kernel"
ssh ${MDW} uname -r > ${REPO}/14_kernel_mdw
ssh ${SMDW} uname -r > ${REPO}/14_kernel_smdw
for ((i=1;i<=${SDW_CNT};i++))
do
		ssh sdw$i uname -r > ${REPO}/14_kernel_sdw$i
	done
kernel_result=`cat ${REPO}/14_kernel_mdw`
echo "$kernel_result"
echo ""
kernel_diff=`for ((i=1;i<=${SDW_CNT};i++))
	do
		diff -q ${REPO}/14_kernel_mdw ${REPO}/14_kernel_sdw$i
	done
		diff -q ${REPO}/14_kernel_mdw ${REPO}/14_kernel_smdw`
if [ ! -n "$kernel_diff" ]; then
	echo -e "\033[92m"[NORMAL : ALL SEGMENTS SAME]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!! : CHECK FOLLOW MESSAGE]"\033[0m"
fi
echo "$kernel_diff"

echo ""
echo "=============================="
echo "15. mtu"
ssh ${MDW} ifconfig | grep mtu > ${REPO}/15_mtu_mdw
ssh ${SMDW} ifconfig | grep mtu > ${REPO}/15_mtu_smdw
for ((i=1;i<=${SDW_CNT};i++))
do
		ssh sdw$i ifconfig | grep mtu > ${REPO}/15_mtu_sdw$i
	done
mtu_result=`cat ${REPO}/15_mtu_mdw`
echo "$mtu_result"
echo ""
mtu_diff=`for ((i=1;i<=${SDW_CNT};i++))
	do
		diff -q ${REPO}/15_mtu_mdw ${REPO}/15_mtu_sdw$i
	done
		diff -q ${REPO}/15_mtu_mdw ${REPO}/15_mtu_smdw`
if [ ! -n "$mtu_diff" ]; then
	echo -e "\033[92m"[NORMAL : ALL SEGMENTS SAME]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!! : CHECK FOLLOW MESSAGE]"\033[0m"
fi
echo "$mtu_diff"

echo ""
echo "=============================="
echo "16. df (file usage)"
ssh ${MDW} df -h | grep data > ${REPO}/16_df_mdw
ssh ${SMDW} df -h | grep data > ${REPO}/16_df_smdw
for ((i=1;i<=${SDW_CNT};i++))
do
		ssh sdw$i df -h | grep data > ${REPO}/16_df_sdw$i
	done
df_result=`cat ${REPO}/16_df_*`
echo "$df_result"
echo ""
if [ ! -z "$df_result" ]; then
	echo -e "\033[92m"[ORDER IS AS FOLLOWS : mdw, sdw, smdw]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!! : SOME SEG IS NOT SET]"\033[0m"
fi
echo "$df_result"

echo ""
echo "=============================="
echo "17. fstab (filesystem)"
ssh ${MDW} cat /etc/fstab | grep data > ${REPO}/17_fstab_mdw
ssh ${SMDW} cat /etc/fstab | grep data > ${REPO}/17_fstab_smdw
for ((i=1;i<=${SDW_CNT};i++))
do
		ssh sdw$i cat /etc/fstab | grep data > ${REPO}/17_fstab_sdw$i
	done
fstab_result=`cat ${REPO}/17_fstab_*`
echo "$fstab_result"
echo ""
if [ ! -z "$fstab_result" ]; then
	echo -e "\033[92m"[ORDER IS AS FOLLOWS : mdw, sdw, smdw]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!! : SOME SEG IS NOT SET]"\033[0m"
fi
echo "$fstab_result"

echo ""
echo "=============================="
echo "18. resolv conf"
ssh ${MDW} scp /etc/resolv.conf ${MDW}:${REPO}/18_resolvconf_mdw
ssh ${SMDW} scp /etc/resolv.conf ${MDW}:${REPO}/18_resolvconf_smdw
for ((i=1;i<=${SDW_CNT};i++))
do
		ssh sdw$i scp /etc/resolv.conf ${MDW}:${REPO}/18_resolvconf_sdw$i
	done
resolvconf_result=`cat ${REPO}/18_resolvconf_mdw`
echo "$resolvconf_result"
echo ""
resolvconf_diff=`for ((i=1;i<=${SDW_CNT};i++))
	do
		diff -q ${REPO}/18_resolvconf_mdw ${REPO}/18_resolvconf_sdw$i
	done
		diff -q ${REPO}/18_resolvconf_mdw ${REPO}/18_resolvconf_smdw`
if [ ! -n "$resolvconf_diff" ]; then
	echo -e "\033[92m"[NORMAL : ALL SEGMENTS SAME]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!! : CHECK FOLLOW MESSAGE]"\033[0m"
fi
echo "$resolvconf_diff"

echo ""
echo "=============================="
echo "21. sysctl conf"
ssh ${MDW} scp /etc/sysctl.conf ${MDW}:${REPO}/21_sysctlconf_mdw
ssh ${SMDW} scp /etc/sysctl.conf ${MDW}:${REPO}/21_sysctlconf_smdw
for ((i=1;i<=${SDW_CNT};i++))
do
		ssh sdw$i scp /etc/sysctl.conf ${MDW}:${REPO}/21_sysctlconf_sdw$i
	done
sysctlconf_result=`cat ${REPO}/21_sysctlconf_mdw`
echo "$sysctlconf_result"
echo ""
sysctlconf_diff=`for ((i=1;i<=${SDW_CNT};i++))
	do
		diff -q ${REPO}/21_sysctlconf_mdw ${REPO}/21_sysctlconf_sdw$i
	done
		diff -q ${REPO}/21_sysctlconf_mdw ${REPO}/21_sysctlconf_smdw`
if [ ! -n "$sysctlconf_diff" ]; then
	echo -e "\033[92m"[NORMAL : ALL SEGMENTS SAME]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!! : CHECK FOLLOW MESSAGE]"\033[0m"
fi
echo "$sysctlconf_diff"

echo ""
echo "=============================="
echo "22. grubby"
ssh ${MDW} grubby --info=ALL | grep elevator | grep hugepage > ${REPO}/22_grubby_mdw
ssh ${SMDW} grubby --info=ALL | grep elevator | grep hugepage > ${REPO}/22_grubby_smdw
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
grubby_result=`cat ${REPO}/22_grubby_mdw`
echo "$grubby_result"
echo ""
grubby_diff=`for ((i=1;i<=${SDW_CNT};i++))
        do
                diff -q ${REPO}/22_grubby_mdw ${REPO}/22_grubby_sdw$i
        done
                diff -q ${REPO}/22_grubby_mdw ${REPO}/22_grubby_smdw`
if [ ! -n "$grubby_diff" ]; then
        echo -e "\033[92m"[NORMAL : ALL SEGMENTS SAME]"\033[0m"
else
        echo -e "\033[91m"[WARNING!!! : CHECK FOLLOW MESSAGE]"\033[0m"
fi
echo "$grubby_diff"

echo ""
echo "=============================="
echo "23. ulimit"
ssh ${MDW} scp /etc/security/limits.d/*-nproc.conf ${MDW}:${REPO}/23_ulimit_mdw
ssh ${SMDW} scp /etc/security/limits.d/*-nproc.conf ${MDW}:${REPO}/23_ulimit_smdw
for ((i=1;i<=${SDW_CNT};i++))
do
		ssh sdw$i scp /etc/security/limits.d/*-nproc.conf ${MDW}:${REPO}/23_ulimit_sdw$i
	done
ulimit_result=`cat ${REPO}/23_ulimit_mdw`
echo "$ulimit_result"
echo ""
ulimit_diff=`for ((i=1;i<=${SDW_CNT};i++))
	do
		diff -q ${REPO}/23_ulimit_mdw ${REPO}/23_ulimit_sdw$i
	done
		diff -q ${REPO}/23_ulimit_mdw ${REPO}/23_ulimit_smdw`
if [ ! -n "$ulimit_diff" ]; then
	echo -e "\033[92m"[NORMAL : ALL SEGMENTS SAME]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!! : CHECK FOLLOW MESSAGE]"\033[0m"
fi
echo "$ulimit_diff"

echo ""
echo "=============================="
echo "24. blockdev"
ssh ${MDW} /sbin/blockdev --getra ${BLOCKDEV_DIR} > ${REPO}/24_blockdev_mdw
ssh ${SMDW} /sbin/blockdev --getra ${BLOCKDEV_DIR} > ${REPO}/24_blockdev_smdw
for ((i=1;i<=${SDW_CNT};i++))
do
		ssh sdw$i /sbin/blockdev --getra ${BLOCKDEV_DIR} > ${REPO}/24_blockdev_sdw$i
	done
blockdev_result=`cat ${REPO}/24_blockdev_mdw`
echo "$blockdev_result"
echo ""
blockdev_diff=`for ((i=1;i<=${SDW_CNT};i++))
	do
		diff -q ${REPO}/24_blockdev_mdw ${REPO}/24_blockdev_sdw$i
	done
		diff -q ${REPO}/24_blockdev_mdw ${REPO}/24_blockdev_smdw`
if [ ! -n "$blockdev_diff" ]; then
	echo -e "\033[92m"[NORMAL : ALL SEGMENTS SAME]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!! : CHECK FOLLOW MESSAGE]"\033[0m"
fi
echo "$blockdev_diff"

echo ""
echo "=============================="
echo "25. logind conf"
ssh ${MDW} scp /etc/systemd/logind.conf ${MDW}:${REPO}/25_loginidconf_mdw
ssh ${SMDW} scp /etc/systemd/logind.conf ${MDW}:${REPO}/25_loginidconf_smdw
for ((i=1;i<=${SDW_CNT};i++))
do
		ssh sdw$i scp /etc/systemd/logind.conf ${MDW}:${REPO}/25_loginidconf_sdw$i
	done
loginidconf_result=`cat ${REPO}/25_loginidconf_mdw | grep IPC`
echo "$loginidconf_result"
echo ""
loginidconf_diff=`for ((i=1;i<=${SDW_CNT};i++))
	do
		diff -q ${REPO}/25_loginidconf_mdw ${REPO}/25_loginidconf_sdw$i
	done
		diff -q ${REPO}/25_loginidconf_mdw ${REPO}/25_loginidconf_smdw`
if [ ! -n "$loginidconf_diff" ]; then
	echo -e "\033[92m"[NORMAL : ALL SEGMENTS SAME]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!! : CHECK FOLLOW MESSAGE]"\033[0m"
fi
echo "$loginidconf_diff"

echo ""
echo "=============================="
echo "26. sshd config"
ssh ${MDW} scp /etc/ssh/sshd_config ${MDW}:${REPO}/26_sshdconfig_mdw
ssh ${SMDW} scp /etc/ssh/sshd_config ${MDW}:${REPO}/26_sshdconfig_smdw
for ((i=1;i<=${SDW_CNT};i++))
do
		ssh sdw$i scp /etc/ssh/sshd_config ${MDW}:${REPO}/26_sshdconfig_sdw$i
	done
sshdconfig_result=`cat ${REPO}/26_sshdconfig_mdw | egrep "MaxStartups|UseDNS"`
echo "$sshdconfig_result"
echo ""
sshdconfig_diff=`for ((i=1;i<=${SDW_CNT};i++))
	do
		diff -q ${REPO}/26_sshdconfig_mdw ${REPO}/26_sshdconfig_sdw$i
	done
		diff -q ${REPO}/26_sshdconfig_mdw ${REPO}/26_sshdconfig_smdw`
if [ ! -n "$sshdconfig_diff" ]; then
	echo -e "\033[92m"[NORMAL : ALL SEGMENTS SAME]"\033[0m"
else
	echo -e "\033[91m"[WARNING!!! : CHECK FOLLOW MESSAGE]"\033[0m"
fi
echo "$sshdconfig_diff"
