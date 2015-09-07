#!/bin/bash		



centosversion=`rpm -qi centos-release  | grep Version | awk '{ print $3}'`


#----------------------------------------------
echo 'Starting Package Upgrades'

if [ -x /usr/bin/yum ]; then
	echo "Yum"
	yum -y upgrade
elif [ -x /usr/bin/apt-get ]; then
	echo "Apt"
	apt-get update
	apt-get upgrade -y
else
	echo -n "Unhandled OS: "
	cat /etc/issue
fi

#----------------------------------------------
echo "Installing useful packages"
if [ -x /usr/bin/yum ]; then
	yum localinstall -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-$centosversion.noarch.rpm
	yum install -y puppet screen telnet unzip lsof ntp ntpdate wget sysstat bind-utils htop biosdevname sudo

elif [ -x /usr/bin/apt-get ]; then
	apt-get install puppet screen telnet unzip lsof ntp ntpdate wget sysstat bind-utils sudo -y
else
	echo -n "Unhandled OS: "
	cat /etc/issue
fi

#----------------------------------------------
echo "Don't require tty for sudoers"
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers


#----------------------------------------------
echo "Disable SElinux"
if [ -f /etc/selinux/config ]; then
	sed -i "s/enforcing/permissive/" /etc/selinux/config
fi

#----------------------------------------------
echo 'Install vagrant SSH key'
mkdir -pm 700 /root/.ssh
wget --no-check-certificate https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub -O /root/.ssh/authorized_keys
chmod 0600 /root/.ssh/authorized_keys
chown -R root:root /root/.ssh
echo vagrant | passwd --stdin root



#----------------------------------------------
echo 'Install vagrant user'
adduser vagrant
echo vagrant | passwd --stdin vagrant

mkdir -pm 700 /home/vagrant/.ssh
wget --no-check-certificate https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub -O /home/vagrant/.ssh/authorized_keys
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

echo "vagrant ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/vagrant