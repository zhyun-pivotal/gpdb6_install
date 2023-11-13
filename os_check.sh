#!/bin/bash
##########
### example : sh os_check.sh /home/gpadmin/gpconfigs/hostfile_all
##########
mkdir -p /home/gpadmin/dba/chklog
export LOGFILE=/home/gpadmin/dba/chklog/os_check.$(date '+%Y%m%d_%H%M')
export HOSTFILE=$1

echo "" > $LOGFILE
echo "####################" >> $LOGFILE
echo "### 1. OS version" >> $LOGFILE
echo "####################" >> $LOGFILE
gpssh -f $HOSTFILE 'sudo cat /etc/redhat-release' >> $LOGFILE

echo "" >> $LOGFILE
echo "####################" >> $LOGFILE
echo "### 2. vCPUs" >> $LOGFILE
echo "####################" >> $LOGFILE
gpssh -f $HOSTFILE 'sudo cat /proc/cpuinfo | grep cores | wc -l' >> $LOGFILE

echo "" >> $LOGFILE
echo "####################" >> $LOGFILE
echo "### 3. Memory" >> $LOGFILE
echo "####################" >> $LOGFILE
gpssh -f $HOSTFILE 'sudo cat /proc/meminfo | grep "MemTotal"' >> $LOGFILE

echo "" >> $LOGFILE
echo "####################" >> $LOGFILE
echo "### 4. Filesystem" >> $LOGFILE
echo "####################" >> $LOGFILE
gpssh -f $HOSTFILE 'sudo df -h' >> $LOGFILE

echo "" >> $LOGFILE
echo "####################" >> $LOGFILE
echo "### 5. sysctl.conf" >> $LOGFILE
echo "####################" >> $LOGFILE
gpssh -f $HOSTFILE 'sudo cat /etc/sysctl.conf | grep -v "#"' >> $LOGFILE

echo "" >> $LOGFILE
echo "####################" >> $LOGFILE
echo "### 6. Firewall" >> $LOGFILE
echo "####################" >> $LOGFILE
gpssh -f $HOSTFILE 'sudo cat /etc/selinux/config | grep "SELINUX="' >> $LOGFILE
echo "" >> $LOGFILE
gpssh -f $HOSTFILE 'sudo systemctl status firewalld.service | grep "Active"' >> $LOGFILE

echo "" >> $LOGFILE
echo "####################" >> $LOGFILE
echo "### 7. Resource Limit" >> $LOGFILE
echo "####################" >> $LOGFILE
gpssh -f $HOSTFILE 'ulimit -Sa | egrep "open|processes|core"' >> $LOGFILE
echo "" >> $LOGFILE
gpssh -f $HOSTFILE 'ulimit -Ha | egrep "open|processes|core"' >> $LOGFILE

echo "" >> $LOGFILE
echo "####################" >> $LOGFILE
echo "### 8. XFS Mount" >> $LOGFILE
echo "####################" >> $LOGFILE
gpssh -f $HOSTFILE 'sudo cat /etc/fstab | egrep "xfs"' >> $LOGFILE

echo "" >> $LOGFILE
echo "####################" >> $LOGFILE
echo "### 9. Disk I/O" >> $LOGFILE
echo "####################" >> $LOGFILE
### pre-check the /data filesystem device by df -h command
gpssh -f $HOSTFILE 'sudo /sbin/blockdev --getra /dev/sd*' >> $LOGFILE
echo "" >> $LOGFILE
gpssh -f $HOSTFILE 'sudo /sbin/blockdev --getra /dev/mapper/*' >> $LOGFILE

echo "" >> $LOGFILE
echo "####################" >> $LOGFILE
echo "### 10. Transparent Huge Page" >> $LOGFILE
echo "####################" >> $LOGFILE
gpssh -f $HOSTFILE 'sudo grubby --info=ALL | grep "elevator"' >> $LOGFILE

echo "" >> $LOGFILE
echo "####################" >> $LOGFILE
echo "### 11. IPC" >> $LOGFILE
echo "####################" >> $LOGFILE
gpssh -f $HOSTFILE 'sudo cat /etc/systemd/logind.conf | grep IPC | grep -v "#"' >> $LOGFILE

echo "" >> $LOGFILE
echo "####################" >> $LOGFILE
echo "### 12. SSH connection" >> $LOGFILE
echo "####################" >> $LOGFILE
gpssh -f $HOSTFILE 'sudo cat /etc/ssh/sshd_config | egrep "MaxStartup|UseDNS" | grep -v "#"' >> $LOGFILE

echo "" >> $LOGFILE
echo "####################" >> $LOGFILE
echo "### 13. NTP" >> $LOGFILE
echo "####################" >> $LOGFILE
gpssh -f $HOSTFILE 'sudo systemctl status chronyd' >> $LOGFILE
echo "" >> $LOGFILE
gpssh -f $HOSTFILE 'sudo date' >> $LOGFILE
