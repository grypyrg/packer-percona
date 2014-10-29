#!/bin/bash		

# Ensure udev doesn't mess with the network
echo "Ensuring udev doesn't mess with the network..."
rm -f /etc/udev/rules.d/70-persistent-net.rules


# Special sauce for CentOS 7 for whacky network device names
if [ -f /etc/sysconfig/network-scripts/ifcfg-enp0s3 ] || [ -f /etc/sysconfig/network-scripts/ifcfg-ens33 ]; then
  echo "Special CentOS 7 sauce"
  if [ -f /etc/sysconfig/network-scripts/ifcfg-enp0s3 ];
  then
    mv /etc/sysconfig/network-scripts/ifcfg-enp0s3 /etc/sysconfig/network-scripts/ifcfg-eth0
  fi
  if [ -f /etc/sysconfig/network-scripts/ifcfg-ens33 ];
  then
    mv /etc/sysconfig/network-scripts/ifcfg-ens33 /etc/sysconfig/network-scripts/ifcfg-eth0
  fi
  
  touch /etc/udev/rules.d/60-net.rules
  
  sed -i 's/quiet"$/quiet net.ifnames=0 biosdevname=0"/' /etc/default/grub
  grub2-mkconfig -o /boot/grub2/grub.cfg
fi

sed -i 's/^HWADDR.*$//' /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i 's/^UUID.*$//' /etc/sysconfig/network-scripts/ifcfg-eth0