#!/bin/bash
mkdir -p /home/gpadmin/dba/diaglog
export LOGFILE=/home/gpadmin/dba/diaglog/diag_os.$(date '+%Y%m%d_%H%M')
export HOSTFILE=/home/gpadmin/gpconfigs/hostfile_all

OSVER=`cat /etc/redhat-release | awk '{print $4}' | awk -F'.' '{print $1'}`

echo "" > ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 0. Memory config check" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
gpssh -f ${HOSTFILE} sudo echo "kernel.shmall = "$(expr $(getconf _PHYS_PAGES) / 2) >> ${LOGFILE}
echo "" >> ${LOGFILE}
gpssh -f ${HOSTFILE} sudo echo "kernel.shmmax = "$(expr $(getconf _PHYS_PAGES) / 2 \* $(getconf PAGE_SIZE)) >> ${LOGFILE}
echo "" >> ${LOGFILE}
gpssh -f ${HOSTFILE} sudo grep 'MemTotal' /proc/meminfo | awk -F']' '{print $2}' | awk '{OFMT = "%.0f";} {print "vm.min_free_kbytes =", $2 * .03;}' >> ${LOGFILE}

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 1. OS version" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'sudo cat /etc/redhat-release' >> ${LOGFILE}

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 2. vCPUs" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'sudo cat /proc/cpuinfo | grep cores | wc -l' >> ${LOGFILE}

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 3. Memory" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'sudo cat /proc/meminfo | grep "MemTotal"' >> ${LOGFILE}

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 4. Filesystem" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'sudo df -h' >> ${LOGFILE}

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 5. sysctl.conf" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'sudo cat /etc/sysctl.conf | grep -v "#" | grep -v ^$' >> ${LOGFILE}
echo "" >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'echo "kernel.shmall = " `cat /proc/sys/kernel/shmall`' >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'echo "kernel.shmmax = " `cat /proc/sys/kernel/shmmax`' >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'echo "kernel.shmmni = " `cat /proc/sys/kernel/shmmni`' >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'echo "vm.overcommit_memory = " `cat /proc/sys/vm/overcommit_memory`' >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'echo "vm.overcommit_ratio = " `cat /proc/sys/vm/overcommit_ratio`' >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'echo "net.ipv4.ip_local_port_range = " `cat /proc/sys/net/ipv4/ip_local_port_range`' >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'echo "kernel.sem = " `cat /proc/sys/kernel/sem`' >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'echo "kernel.sysrq = " `cat /proc/sys/kernel/sysrq`' >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'echo "kernel.core_uses_pid = " `cat /proc/sys/kernel/core_uses_pid`' >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'echo "kernel.msgmnb = " `cat /proc/sys/kernel/msgmnb`' >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'echo "kernel.msgmax = " `cat /proc/sys/kernel/msgmax`' >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'echo "kernel.msgmni = " `cat /proc/sys/kernel/msgmni`' >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'echo "net.ipv4.tcp_syncookies = " `cat /proc/sys/net/ipv4/tcp_syncookies`' >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'echo "net.ipv4.conf.default.accept_source_route = " `cat /proc/sys/net/ipv4/conf/default/accept_source_route`' >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'echo "net.ipv4.tcp_max_syn_backlog = " `cat /proc/sys/net/ipv4/tcp_max_syn_backlog`' >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'echo "net.ipv4.conf.all.arp_filter = " `cat /proc/sys/net/ipv4/conf/all/arp_filter`' >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'echo "net.ipv4.ipfrag_high_thresh = " `cat /proc/sys/net/ipv4/ipfrag_high_thresh`' >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'echo "net.ipv4.ipfrag_low_thresh = " `cat /proc/sys/net/ipv4/ipfrag_low_thresh`' >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'echo "net.ipv4.ipfrag_time = " `cat /proc/sys/net/ipv4/ipfrag_time`' >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'echo "net.core.netdev_max_backlog = " `cat /proc/sys/net/core/netdev_max_backlog`' >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'echo "net.core.rmem_max = " `cat /proc/sys/net/core/rmem_max`' >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'echo "net.core.wmem_max = " `cat /proc/sys/net/core/wmem_max`' >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'echo "vm.swappiness = " `cat /proc/sys/vm/swappiness`' >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'echo "vm.zone_reclaim_mode = " `cat /proc/sys/vm/zone_reclaim_mode`' >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'echo "vm.dirty_expire_centisecs = " `cat /proc/sys/vm/dirty_expire_centisecs`' >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'echo "vm.dirty_writeback_centisecs = " `cat /proc/sys/vm/dirty_writeback_centisecs`' >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'echo "vm.dirty_background_ratio = " `cat /proc/sys/vm/dirty_background_ratio`' >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'echo "vm.dirty_ratio = " `cat /proc/sys/vm/dirty_ratio`' >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'echo "vm.dirty_background_bytes = " `cat /proc/sys/vm/dirty_background_bytes`' >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'echo "vm.dirty_bytes = " `cat /proc/sys/vm/dirty_bytes`' >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'echo "kernel.core_pattern = " `cat /proc/sys/kernel/core_pattern`' >> ${LOGFILE}

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 6. Firewall" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'sudo cat /etc/selinux/config | grep "SELINUX="' >> ${LOGFILE}
echo "" >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'sudo systemctl status firewalld.service | grep "Active"' >> ${LOGFILE}

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 7. Resource Limit" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'ulimit -Sa | egrep "open|processes|core"' >> ${LOGFILE}
echo "" >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'ulimit -Ha | egrep "open|processes|core"' >> ${LOGFILE}

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 8. XFS Mount" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'sudo cat /etc/fstab | egrep "xfs"' >> ${LOGFILE}

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 9. Disk I/O" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
### pre-check the /data filesystem device by df -h command
gpssh -f ${HOSTFILE} 'sudo /sbin/blockdev --getra /dev/sd*' >> ${LOGFILE}
echo "" >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'sudo /sbin/blockdev --getra /dev/mapper/*' >> ${LOGFILE}

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 10. Transparent Huge Page" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'sudo grubby --info=ALL | grep "elevator"' >> ${LOGFILE}

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 11. IPC" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'sudo cat /etc/systemd/logind.conf | grep IPC | grep -v "#"' >> ${LOGFILE}

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 12. SSH connection" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'sudo cat /etc/ssh/sshd_config | egrep "MaxStartup|UseDNS" | grep -v "#"' >> ${LOGFILE}

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 13. NTP" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
if [ ${OSVER} -eq 8 ]
then
  gpssh -f ${HOSTFILE} 'sudo systemctl status chronyd' >> ${LOGFILE}
else
  gpssh -f ${HOSTFILE} 'sudo systemctl status ntpd' >> ${LOGFILE}
fi
echo "" >> ${LOGFILE}
gpssh -f ${HOSTFILE} 'sudo date' >> ${LOGFILE}
