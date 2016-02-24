include_recipe 'apache2'

Chef::Resource::User.send(:include, Utils::Helper)

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
  only_if { missing_php? }
end

execute "apt-get update" do
  command "sudo apt-get update"
  only_if { missing_php? }
end

node[:mod_php5_apache2][:packages].each do |pkg|
  package pkg do
    action :install
    options '--force-yes'
    ignore_failure(pkg.to_s.match(/^php-pear-/) ? true : false) # some pear packages come from EPEL which is not always available
  end
end

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'php'
    Chef::Log.debug("Skipping deploy::php application #{application} as it is not an PHP app")
    next
  end
  next if node[:deploy][application][:database].nil?

  bash "Enable network database access for httpd" do
    boolean = "httpd_can_network_connect_db"
    user "root"
    code <<-EOH
      semanage boolean --modify #{boolean} --on
    EOH
    not_if { OpsWorks::ShellOut.shellout("/usr/sbin/getsebool #{boolean}") =~ /#{boolean}\s+-->\s+on\)/ }
    only_if { platform_family?("rhel") && ::File.exist?("/usr/sbin/getenforce") && OpsWorks::ShellOut.shellout("/usr/sbin/getenforce").strip == "Enforcing" }
  end

  case node[:deploy][application][:database][:type]
  when "postgresql"
    include_recipe 'mod_php5_apache2::postgresql_adapter'
  else # mysql or just backwards compatible
    include_recipe 'mod_php5_apache2::mysql_adapter'
  end
end

include_recipe 'apache2::mod_php5'
