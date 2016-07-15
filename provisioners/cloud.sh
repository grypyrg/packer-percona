#!/bin/sh


#----------------------------------------------
# the 32bit amazon AMI instance is built from 
# http://www.nixknight.com/2014/04/build-ebs-backed-centos-ec2-ami-from-scratch/
# 
# However, we don't want to use it anymore. i want to use cloud-init to setup 
# my accounts. so we need to remove the /etc/rc.local hack.
# Making a new AMI is time consuming so this will work too :-)
#

if [ "3376ff19b847690778b317b9500a2178" == "`md5sum /etc/rc.d/rc.local | awk '{print $1}'`" ]; then
	cat > /etc/rc.d/rc.local << EOF
#!/bin/sh
#
# This script will be executed *after* all the other init scripts.
# You can put your own initialization stuff in here if you don't
# want to do the full Sys V style init stuff.
 
touch /var/lock/subsys/local
EOF
fi


#----------------------------------------------
if [ $PACKER_BUILDER_TYPE == "amazon-ebs" ]
then
	echo "EC2 -- set device names"
	echo "options xen_blkfront sda_is_xvda=1" > /etc/modprobe.d/xen_blkfront.conf
	sed -i 's/xvde/xvda/' /etc/fstab
fi

#----------------------------------------------
# This is for centos7 which uses cloud-init
if [ -f /etc/cloud/cloud.cfg ]; then
	echo "Configure cloud-init"

# - we don't want root@ssh
# - we don't want ssh pw authentication
#	sed -i "s/^disable_root: 1$/disable_root: 0/" /etc/cloud/cloud.cfg
#	sed -i "s/^ssh_pwauth:   0$/ssh_pwauth:   1/" /etc/cloud/cloud.cfg
	sed -i "s/^ssh_deletekeys:   0$/ssh_deletekeys:   1/" /etc/cloud/cloud.cfg
	sed -i "s/^    name: centos$/    name: vagrant/" /etc/cloud/cloud.cfg
	sed -i "/^ - mounts"/d /etc/cloud/cloud.cfg
fi


#----------------------------------------------
# remove root authorized keys after finish
rm -f /root/.ssh/authorized_keys

#----------------------------------------------
echo "Removing any network-scripts/ifcfg-e*"
rm -f /etc/sysconfig/network-scripts/ifcfg-e*



sync && sleep 1 && sync




