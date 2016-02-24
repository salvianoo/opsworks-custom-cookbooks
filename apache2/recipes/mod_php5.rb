# Cookbook Name:: apache2
# Recipe:: mod_php7
#
["build-essential",
  "python-software-properties",
  "git"
].each do |pkg|
    apt_package pkg do
      action :install
    end
  end

# add php 7.0 repository
execute "add-apt-repository" do
  command "add-apt-repository ppa:ondrej/php"
end

execute "apt-get update" do
  command "sudo apt-get update"
end

case node[:platform_family]
when 'debian'
  package 'libapache2-mod-php7.0' do
    action :install
  end
when 'rhel'
  package 'php' do
    action :install
    notifies :run, "execute[generate-module-list]", :immediately
    not_if 'which php'
  end

  # remove stock config
  file File.join(node[:apache][:dir], 'conf.d', 'php.conf') do
    action :delete
  end

  # replace with debian config
  template File.join(node[:apache][:dir], 'mods-available', 'php5.conf') do
    source 'mods/php5.conf.erb'
    notifies :restart, "service[apache2]"
  end
end

apache_module 'php5' do
  if platform_family?('rhel')
    filename 'libphp5.so'
  end
end