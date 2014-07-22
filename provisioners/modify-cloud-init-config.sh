#!/bin/sh

if [ -f /etc/cloud/cloud.cfg ]; then
  echo 'Allowing root login via cloud-init'
  sed -i "s/^disable_root: 1/disable_root: 0/" /etc/cloud/cloud.cfg

  echo 'Allowing password logins'
  sed -i "s/^ssh_pwauth:   0/ssh_pwauth:   1/" /etc/cloud/cloud.cfg

  echo 'Skip mounting extra storage'
  sed -i "/^ - mounts/d" /etc/cloud/cloud.cfg
fi
