#
# Cookbook Name:: memcached
# Recipe:: default
#
# Copyright 2011, Evolving Web, Inc.
#
# All rights reserved - Do Not Redistribute
#

%w{memcached libmemcached-dev}.each do |pkg|
  package pkg
end

template '/etc/init.d/memcached' do
  source 'init.erb'
  mode 0744
  owner 'root'
  group 'root'
end

file '/etc/default/memcached' do
  backup 1
  mode '0744'
  group 'root'
  owner 'root'
  content "# Empty file generated by chef for #{node[:fqdn]}"
end
