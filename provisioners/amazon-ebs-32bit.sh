#!/bin/sh

#----------------------------------------------
# amazon AMI instance is built from 
# http://www.nixknight.com/2014/04/build-ebs-backed-centos-ec2-ami-from-scratch/
# 
# we want rc.local to reexecute everything
echo "Cleanup -- making sure password gets regenerated"
touch /root/firstrun
echo "Cleanup -- removing authorized_keys for root"
rm -rf /root/.ssh/authorized_keys
