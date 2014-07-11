#!/bin/sh

echo 'Removing root authorized_keys so EC2 will auto-populate it'
rm -f /root/.ssh/authorized_keys


if [ -f /etc/cloud/cloud.cfg ]; then
  echo 'Allowing root login via cloud-init'
  sed -i "s/^disable_root: 1/disable_root: 0/" /etc/cloud/cloud.cfg
fi
