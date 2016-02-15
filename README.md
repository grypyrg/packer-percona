# Packer Percona

The goal of these packer builds is to create consistent Vagrant boxes across multiple vagrant providers, specifically for Percona vagrant usage.  Currently only Virtualbox and EC2 are supported.

These setups are typically for the purposes of internal testing and demonstration purposes and don't necessarily reflect recommended production settings.  

## Atlas

You can find the builds of these packer images on Atlas:

- https://atlas.hashicorp.com/grypyrg/boxes/centos-x86_64
- https://atlas.hashicorp.com/grypyrg/boxes/centos-i386

## Setup

Required Software:

* Packer 0.5.1+: http://packer.io
* Vagrant: http://vagrantup.com


And one or all of the following for the associated box types to get created:

* AWS account with standard access credentials: http://aws.amazon.com (optional)
* Virtualbox http://virtualbox.org (optional)

### AWS

Put your access and secret keys in environment variables in your .bashrc or similar (for packer):

```bash
export AWS_ACCESS_KEY_ID=YOUR_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=THE_ASSOCIATED_SECRET_KEY
```


## Building

Currently only CentOS 6 is up to date.  Ubuntu and other Linux types are feasible with Packer.

* Modify centos6.json as desired
 * Source AMI
 * Region

```bash
packer validate centos-6_5-64.json
packer build centos-6_5-64.json
vagrant box add centos-6_5-64_percona centos-6_5-64_percona_virtualbox.box
vagrant box add centos-6_5-64_percona centos-6_5-64_percona_aws.box
cd ..
```

This will add boxes for each of the providers packer builds a box for.  You can optionally just build a box for specific provider like this:

```bash
packer build --only=virtualbox-iso centos-6_5-64.json
packer build --only=amazon-ebs centos-6_5-64.json
```

Once you are done building boxes, they will be located in the 'boxes' subdir.  You can manually load them using 'vagrant box add' or use the 'load_boxes.sh' to add all boxes and replace any that may already be in Vagrant.


## Nuances

* These boxes assume Vagrant is logging in with 'vagrant'
* These boxes should be updated to the latest package releases on build
* An extra device or logical volume is available (and possibly setup) for /var/lib/mysql  (note: for AWS you can configure these at the vagrant-aws level now, so we will leave this unset for EC2 instances)

### Local Percona package repository

These boxes contain a local repository that is disabled by default containing recent releases of Percona software.  This repo can be enabled for the purposes of using these boxes in situations with poor or no internet connectivity. (E.g., conferences)

## OSes

### CentOS 6 builds

The VM-based builds use a netinstall ISO and a kickstart file to provision the box.   This guarantees all packages are up to date at the time of the build.

AWS uses an official CentOS 6 AMI "with Updates".  http://wiki.centos.org/Cloud/AWS  These are Region-specific, so you'll need a different AMI identifier for different AWS regions.
However, with changes to the way the Marketplace works. It's not longer possible to create a new AMI based on an AMI from the workplace. Custom AMI's were build from scratch.


### Ubuntu 

Ubuntu packages were not implemented yet

## Providers

### Virtualbox

Local VM -- a favorite for conference tutorials.  

http://virtualbox.org

### Amazon EC2 - EBS AMI

Creates an EBS-based AMI associated with a specific AWS Region.  

The current instance comes with no extra EBS volumes because these can be added at the Vagrant level.  However, you can create AMIs with the EBS volumes pre-defined.  An example of such a configuratuion creating a 100GB volume with 1000 provisioned IOPS:

```javascript
    "ami_block_device_mappings": [
      {
        "device_name": "/dev/sda",
        "delete_on_termination": true
      },
      {
        "device_name": "/dev/sdf",
        "virtual_name": "mysql_data",
        "volume_size": 100,
        "volume_type": "io1",
        "iops": 1000,
        "delete_on_termination": true
      }
    ]
```

### OpenStack

During the history of `packer-percona` boxes were also built for vmware and OpenStack. This is no long the case until there is a need for it

### VMWare

During the history of `packer-percona` boxes were also built for vmware and OpenStack. This is no long the case until there is a need for it

## Maintenance

Packer will cruft up your EC2 dashboard.  In particular, pay attention and periodically delete:

* Old AMIs
* Unused EBS volumes left over from AMI creation
