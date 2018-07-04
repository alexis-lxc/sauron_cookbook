app_name = node['app_name']
github_repo = 'alexis-lxc/sauron'
release_name = Github.release_name(github_repo)
release_file = Github.release_file(github_repo)

sauron_script_location = node['sauron_script_location']
command_name = node['command_name']

apt_repository 'brightbox-ruby' do
  uri 'ppa:brightbox/ruby-ng'
end

apt_update 'update' do
  action :update
end

package %w(software-properties-common ruby2.5 ruby2.5-dev nodejs build-essential patch ruby-dev zlib1g-dev liblzma-dev libpq-dev) do
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

directory "/opt/#{app_name}/.config/lxc" do
  owner app_name
  group app_name
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

file "/etc/default/#{app_name}.conf" do
  owner app_name
  group app_name
  content node['environment_variables'].map {|k,v| "#{k}=#{v}"}.join("\n")
end

file "/etc/default/#{app_name}.conf.tmp" do
  owner app_name
  group app_name
  content node['environment_variables'].map {|k,v| "export #{k}=#{v}"}.join("\n")
end

tar_extract release_file  do
  target_dir "/opt/#{app_name}/#{release_name}"
  download_dir "/opt/#{app_name}"
  creates "#{release_name}/Gemfile"
  user "#{app_name}"
  group "#{app_name}"
end

link "/opt/#{app_name}/#{app_name}"  do
  to "/opt/#{app_name}/#{release_name}"
  action :create
  user app_name
  group app_name
end

template "/etc/puma/#{app_name}.rb" do
  source "puma.conf.erb"
  owner app_name
  group app_name
  variables( 
    app_name: app_name,
    app_home: app_name
  )
  mode "400"
end

template sauron_script_location do
  source "sauron_script.sh.erb"
  mode   "0755"
  owner app_name
  group app_name
  variables( app_name: app_name, app_home: app_name, command_name: command_name )
  notifies :restart, "service[puma]", :delayed
end

template "/etc/systemd/system/puma.service" do
  source "systemd.erb"
  owner app_name
  group app_name
  mode "00644"
  variables( app_name: app_name, app_home: app_name, sauron_script_location: sauron_script_location )
  notifies :run, "execute[systemctl-daemon-reload]", :immediately
  notifies :restart, "service[puma]", :delayed
end

execute 'systemctl-daemon-reload' do
  command '/bin/systemctl --system daemon-reload'
end

execute 'create-client-certificates' do
  user app_name
  cwd "/opt/#{app_name}/.config/lxc"
  command 'openssl req -new -newkey rsa:4096 -days 50000 -nodes -x509 -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com" -keyout client.key  -out client.crt'
end

service "puma" do
  supports :status => true, :start => true, :restart => true, :stop => true
  provider Chef::Provider::Service::Systemd
  action [:enable, :restart]
end
