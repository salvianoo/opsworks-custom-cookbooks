# add php 7.0 repository
execute "add-apt-repository" do
  command "add-apt-repository ppa:ondrej/php"
end

execute "apt-get update" do
  command "sudo apt-get update"
end

node['system']['packages'].each do |pkg|
  apt_package pkg do
    action :install
  end
end
