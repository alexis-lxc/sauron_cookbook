app_name = node['app_name']
github_repo = 'alexis-lxc/sauron'
release_name = Github.release_name(github_repo)
release_file = Github.release_file(github_repo)

apt_repository 'brightbox-ruby' do
  uri 'ppa:brightbox/ruby-ng'
end

apt_update 'update' do
  action :update
end

package %w(software-properties-common ruby2.4 ruby2.4-dev nodejs build-essential patch ruby-dev zlib1g-dev liblzma-dev libpq-dev ruby-switch) do
  action :install
end

gem_package 'bundler'

group app_name do
  action :create
  gid 2000
end

user app_name do
  comment 'sauron user'
  uid 2000
  gid 2000
  home "/opt/#{app_name}"
  manage_home true
  shell '/bin/bash'
  action :create
end

directory "/opt/#{app_name}/#{release_name}" do
  owner app_name
  group app_name
  recursive true
  action :create
end

directory "/etc/puma" do
  owner 'root'
  group 'root'
  recursive true
  action :create
end

directory "/var/run/#{app_name}" do
  owner app_name
  group app_name
  mode 0755
  recursive true
  action :create
end

