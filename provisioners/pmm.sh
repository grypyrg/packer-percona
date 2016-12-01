#!/bin/bash

echo 'Starting Package Upgrades'
yum -y upgrade

echo "Installing useful packages"
yum -y install cloud-init

echo "Installing Docker"
yum -y install docker
systemctl start docker
systemctl enable docker.service

echo "Create PMM"
docker create \
   -v /opt/prometheus/data \
   -v /opt/consul-data \
   -v /var/lib/mysql \
   -v /var/lib/grafana \
   --name pmm-data \
   percona/pmm-server:1.0.6 /bin/true

docker run -d \
   -p 80:80 \
   --volumes-from pmm-data \
   --name pmm-server \
   --restart always \
   percona/pmm-server:1.0.6


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