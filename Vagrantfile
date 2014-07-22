# -*- mode: ruby -*-
# vi: set ft=ruby :
# Vagrantfile example using these boxes
require 'yaml'


def provider_aws( name, config, instance_type, region = nil, security_groups = nil, hostmanager_aws_ips = nil )
    require 'yaml'

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

Vagrant.configure("2") do |config|
	config.vm.box = "centos-6_5-64_percona"
	#config.vm.box = "perconajayj/centos-x86_64"
	config.ssh.username = "vagrant"
	config.vm.network "private_network", ip: "192.168.50.4"

	provider_aws( 'Packer test server', config, 'm1.small', 'us-west-1' ) do | aws, override |
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

	# Add provisioner info here

end
