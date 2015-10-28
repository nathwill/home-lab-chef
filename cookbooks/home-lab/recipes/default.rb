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
package %w( psmisc lsof net-tools procps yum-utils iptables iptables-services )

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
node['ifcfg'].each_pair do |iface, config|
  file "/etc/sysconfig/network-scripts/ifcfg-#{iface}" do
    content config.map { |conf, val| "#{conf.upcase}=\"#{val}\"" }
    notifies :restart, 'service[network]', :delayed
  end
end

service 'network' do
  action [:enable, :start]
end
