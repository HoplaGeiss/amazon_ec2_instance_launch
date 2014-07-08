#!/usr/bin/ruby
 
# README
# gem install aws-sdk
# add this to bashrc
# export HT_DEV_AWS_ACCESS_KEY_ID=????
# export HT_DEV_AWS_SECRET_ACCESS_KEY=????
# put your pem file in ~/.ssh and chmod 0400
# for more info see; https://rubygems.org/gems/aws-sdk
 
require 'rubygems'
require 'aws-sdk'
 
AWS.config(:access_key_id => ENV['HT_DEV_AWS_ACCESS_KEY_ID'],
:secret_access_key => ENV['HT_DEV_AWS_SECRET_ACCESS_KEY'])

ec2 = AWS::EC2.new.regions['eu-west-1'] # choose region here
image_name = 'ami-776d9700' # which AMI to search for and use
key_pair_name = 'filax2' # key pair name
security_group_name = 'websocket_experiment' # security group name
instance_type = 'm3.2xlarge' # machine instance type (must be approriate for chosen AMI)
ssh_username = 'ubuntu' # default user name for ssh'ing

# find or create a key pair
key_pair = ec2.key_pairs[key_pair_name]
puts "Using keypair #{key_pair.name}"

# find security group
security_group = ec2.security_groups.find{|sg| sg.name == security_group_name }
puts "Using security group: #{security_group.name} \n\n"

# create the instance (and launch it)
instance = ec2.instances.create(:image_id => image_name,
:instance_type => instance_type,
:count => 1,
:security_groups => security_group,
:key_pair => key_pair)
puts "Launching machine ...\n\n"

# wait until battle station is fully operational
sleep 1 until instance.status != :pending
puts "Launched instance #{instance.id}, status: #{instance.status}, public dns: #{instance.dns_name}, public ip: #{instance.ip_address}"
exit 1 unless instance.status == :running

# machine is ready, ssh to it and run a commmand
puts "Launched: You can SSH to it with:"
puts "ssh #{ssh_username}@#{instance.ip_address}"
