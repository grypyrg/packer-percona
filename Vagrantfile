# -*- mode: ruby -*-
# vi: set ft=ruby :
# Vagrantfile example using these boxes
require 'yaml'


def provider_aws( name, config, instance_type, region = nil, security_groups = nil, hostmanager_aws_ips = nil, subnet_id = nil )
    require 'yaml'
    require 'vagrant-aws'

    aws_secrets_file = File.join( Dir.home, '.aws_secrets' )

    if( File.readable?( aws_secrets_file ))
        config.vm.provider :aws do |aws, override|
            aws.instance_type = instance_type

            aws_config = YAML::load_file( aws_secrets_file )
            aws.access_key_id = aws_config.fetch("access_key_id")
            aws.secret_access_key = aws_config.fetch("secret_access_key")

            aws.tags = {
                'Name' => aws_config.fetch("instance_name_prefix") + " " + name
            }

            if subnet_id != nil
                aws.subnet_id = subnet_id
                aws.associate_public_ip = true
            end

            if region == nil
                aws.keypair_name = aws_config["keypair_name"]
                override.ssh.private_key_path = aws_config["keypair_path"]
            else
                aws.region = region
                aws.keypair_name = aws_config['regions'][region]["keypair_name"]
                override.ssh.private_key_path = aws_config['regions'][region]["keypair_path"]
            end

            if security_groups != nil
                aws.security_groups = security_groups
            end

            if Vagrant.has_plugin?("vagrant-hostmanager")

                if hostmanager_aws_ips == "private"
                    awsrequest = "local-ipv4"
                elsif hostmanager_aws_ips == "public"
                    awsrequest = "public-ipv4"
                end

                override.hostmanager.ip_resolver = proc do |vm|
                    result = ''
                    vm.communicate.execute("curl -s http://instance-data/latest/meta-data/" + awsrequest + " 2>&1") do |type,data|
                        result << data if type == :stdout
                    end
                    result
                end
            end

            yield( aws, override )
        end
    else
        puts "Skipping AWS because of missing/non-readable #{aws_secrets_file} file.  Read https://github.com/jayjanssen/vagrant-percona/blob/master/README.md#aws-setup for more information about setting up AWS."
    end
end


def provider_openstack( name, config, flavor, security_groups = nil, networks = nil, floating_ip = nil )
    require 'yaml'
    require 'vagrant-openstack-plugin'

    os_secrets_file = File.join( Dir.home, '.openstack_secrets' )

    if( File.readable?( os_secrets_file ))
        config.vm.provider :openstack do |os, override|
            os.flavor = flavor

            os_config = YAML::load_file( os_secrets_file )

            os.endpoint = os_config.fetch("endpoint")
            os.username = os_config.fetch("username")
            os.api_key = os_config.fetch("password")
            os.tenant= os_config.fetch("tenant")

            os.keypair_name = os_config.fetch("keypair_name")
            override.ssh.private_key_path = os_config.fetch("private_key_path")


            if security_groups != nil
                os.security_groups = security_groups
            end

            if networks != nil
                os.networks = networks
            end


            if floating_ip != nil
                os.floating_ip = floating_ip
                os.floating_ip_pool = :auto
            end

            if block_given?
                yield( os, override )
            end
        end
    else
        puts "Skipping Openstack because of missing/non-readable #{os_secrets_file} file.  Read https://github.com/jayjanssen/vagrant-percona/blob/master/README.md#os-setup for more information about setting up Openstack."
    end
end


Vagrant.configure("2") do |config|
	#config.vm.box = "centos-6_5-64_percona"
	config.vm.box = "centos-7-64_percona"
	#config.vm.box = "perconajayj/centos-x86_64"
	config.ssh.username = "root"
    config.vm.network "private_network", type: "dhcp"

	provider_aws( 'Packer test server', config, 't2.small', 'us-east-1', nil, nil, 'subnet-896602d0' ) do | aws, override |
		# Block device mapping will work when vagrant-aws 0.3 is released.
		# Until then, this config will not work and must be done at the box level in Packer
    aws.block_device_mapping = [
      {
            'DeviceName' => "/dev/sdl",
            'VirtualName' => "mysql_data",
            'Ebs.VolumeSize' => 20,
            'Ebs.DeleteOnTermination' => true
      }
    ]
	end

    provider_openstack( 'Packer test server', config, 'm1.small', nil, ['50285812-3a34-40c5-9e69-0f67fab0ae5c'], '10.60.23.208') do |os, override|

        os.disks = [
            { "name" => "mysql_data", "size" => 10, "description" => "MySQL Data"}
        ]
    end

	# Add provisioner info here

end
