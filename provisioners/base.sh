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
	yum install -y puppet screen telnet unzip lsof ntp ntpdate wget sysstat bind-utils htop biosdevname sudo cloud-init

elif [ -x /usr/bin/apt-get ]; then
	apt-get install puppet screen telnet unzip lsof ntp ntpdate wget sysstat bind-utils sudo cloud-init -y
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
