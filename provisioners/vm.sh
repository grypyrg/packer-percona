#!/bin/bash
# Some of these things are things cloudinit would do

#----------------------------------------------
# we do not longer want root to be used
#echo 'Install vagrant SSH key'
#mkdir -pm 700 /root/.ssh
#wget --no-check-certificate https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub -O /root/.ssh/authorized_keys
#chmod 0600 /root/.ssh/authorized_keys
#chown -R root:root /root/.ssh
# we do not longer want password auth, it's insecure
#echo vagrant | passwd --stdin root



#----------------------------------------------
echo 'Install vagrant user'
adduser vagrant
# we do not longer want password auth, it's insecure
# echo vagrant | passwd --stdin vagrant

mkdir -pm 700 /home/vagrant/.ssh
wget --no-check-certificate https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub -O /home/vagrant/.ssh/authorized_keys
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

echo "vagrant ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/vagrant


#----------------------------------------------
echo "Installing useful VM packages"

if [ -x /usr/bin/yum ]; then
	yum install -y dkms
else
	echo -n "Unhandled OS: "
	cat /etc/issue
fi

#----------------------------------------------
echo "Disabling DNS for SSH"
if [ -f /etc/ssh/sshd_config ]; then
	sed -i "s/#UseDNS yes/UseDNS no/" /etc/ssh/sshd_config
fi


#----------------------------------------------
if [ $PACKER_BUILDER_TYPE == "virtualbox-iso" ]
then
	echo "Installing Vbox Guest Extensions"	
	# Mount the disk image
	cd /tmp
	mkdir /tmp/isomount
	mount -t iso9660 -o loop /root/VBoxGuestAdditions.iso /tmp/isomount

	# Install the drivers
	/tmp/isomount/VBoxLinuxAdditions.run

	# Cleanup
	umount isomount
	rm -rf isomount /root/VBoxGuestAdditions.iso

elif [ $PACKER_BUILDER_TYPE == "vmware-iso" ]
then
	echo "Installing VMware Tools"	

    # Make sure perl is available
    yum -y install perl fuse fuse-libs

    # Mount the disk image
    cd /tmp
    mkdir /tmp/isomount
    mount -t iso9660 -o loop /root/linux.iso /tmp/isomount

    # Install the drivers
    cp /tmp/isomount/VMwareTools-*.gz /tmp
    tar -zxvf VMwareTools*.gz
    ./vmware-tools-distrib/vmware-install.pl -d

    # Cleanup
    umount isomount
    rm -rf isomount /root/linux.iso VMwareTools*.gz vmware-tools-distrib

else
	echo "No VM extensions defined for $PACKER_BUILDER_TYPE"
fi

#----------------------------------------------
echo "Cleaning space for VM size"
if [ -x /usr/bin/yum ]; then
	# Saves ~25M
	yum -y remove kernel-devel
	# Clean cache
	yum clean all
fi

# Clean out all of the caching dirs
rm -rf /var/cache/* /usr/share/doc/*

if [ $PACKER_BUILDER_TYPE == "virtualbox-iso" ]
then
	# Clean up unused disk space so compressed image is smaller.
	cat /dev/zero > /tmp/zero.fill
	rm /tmp/zero.fill
fi


#----------------------------------------------
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

sync && sleep 1 && sync