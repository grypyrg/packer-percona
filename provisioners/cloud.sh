#!/bin/sh

#----------------------------------------------
if [ $PACKER_BUILDER_TYPE == "amazon-ebs" ]
then
	echo "EC2 -- set device names"
	echo "options xen_blkfront sda_is_xvda=1" > /etc/modprobe.d/xen_blkfront.conf
	sed -i 's/xvde/xvda/' /etc/fstab
fi

#----------------------------------------------
if [ -f /etc/cloud/cloud.cfg ]; then
	echo "Configure cloud-init"

	sed -i "s/^disable_root: 1$/disable_root: 0/" /etc/cloud/cloud.cfg
	sed -i "s/^ssh_pwauth:   0$/ssh_pwauth:   1/" /etc/cloud/cloud.cfg
	sed -i "s/^    name: centos$/    name: vagrant/" /etc/cloud/cloud.cfg
	sed -i "/^ - mounts"/d /etc/cloud/cloud.cfg
fi


sync && sleep 1 && sync




