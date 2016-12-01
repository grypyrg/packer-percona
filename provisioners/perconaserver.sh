#!/bin/bash


echo 'Starting Package Upgrades'
yum -y upgrade


echo "Installing useful packages"
yum install cloud-init


echo "Installing Percona Server"
yum -y install http://www.percona.com/downloads/percona-release/redhat/0.1-4/percona-release-0.1-4.noarch.rpm
yum -y install Percona-Server-server-57 Percona-Server-client-57 percona-xtrabackup percona-toolkit


echo "Don't require tty for sudoers"
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers


echo "EC2 -- set device names"
echo "options xen_blkfront sda_is_xvda=1" > /etc/modprobe.d/xen_blkfront.conf
sed -i 's/xvde/xvda/' /etc/fstab


echo "Configure cloud-init"
sed -i "s/^ssh_deletekeys:   0$/ssh_deletekeys:   1/" /etc/cloud/cloud.cfg
sed -i "/^ - mounts"/d /etc/cloud/cloud.cfg


echo "Cleanup"
rm -f /root/.ssh/authorized_keys
rm -f /etc/sysconfig/network-scripts/ifcfg-e*
yum clean all

sync && sleep 1 && sync