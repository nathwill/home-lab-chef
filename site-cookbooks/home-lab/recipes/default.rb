#
# Cookbook Name:: home-lab
# Recipe:: default
#
# Copyright 2015 Nathan Williams
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# remove unwanted defaults
%w( firewalld rsyslog ).each do |svc|
  service svc do
    action %i( disable stop )
  end

  package svc do
    action :remove
  end
end

# add missing essentials
package %w(
  bridge-utils iproute psmisc lsof net-tools
  procps yum-utils iptables iptables-services
)

# Enable default rule-sets
%w( iptables ip6tables ).each do |fw|
  service fw do
    action [:enable, :start]
  end
end

# set up epel
package 'epel-release'

# system base configuration
%w( hostname locale real_time_clock timezone ).each do |r|
  include_recipe "systemd::#{r}"
end

%w( ntp sudo openssh postfix ).each do |cb|
  include_recipe cb
end

# set up the network
network_interface 'br0' do
  type 'Bridge'
  bootproto 'none'
  address node['ipaddress']
  netmask '255.255.255.0'
  gateway node['default_gateway']
  dns %w( 8.8.8.8 8.8.4.4 )
  ipv6init true
  reload_type :delayed
end

network_interface node['ifcfg']['default_if'] do
  type 'Ethernet'
  bootproto 'none'
  bridge_device 'br0'
end

# set up the user
hu = node['home-lab']['user']

user hu do
  home "/home/#{hu}"
  supports manage_home: true
  manage_home true
  shell '/bin/bash'
end

ssh_dir = File.join(resources(user: hu).home, '.ssh')

directory ssh_dir do
  mode '0700'
  owner hu
  group hu
end

remote_file File.join(ssh_dir, 'authorized_keys') do
  source "https://github.com/#{hu}.keys"
  owner hu
  group hu
  mode '0600'
end
