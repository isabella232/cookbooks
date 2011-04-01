#
# Cookbook Name:: users
# Recipe:: root
#

user "root" do
  action :lock
end

directory "/root/.ssh" do
  mode 0700
  owner "root"
  group "root"
end

sysadmin_keys = search(:users, 'groups:sysadmin').map{ |u| u['ssh_keys'] }
system_keys = search(:users, 'groups:system').map{ |u| u['ssh_keys'] }

template "/root/.ssh/authorized_keys" do
  source "authorized_keys.erb"
  mode 0600
  owner "root"
  group "root"
  variables :ssh_keys => sysadmin_keys, :system_keys => system_keys
end