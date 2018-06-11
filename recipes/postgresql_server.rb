root_password = node['database_root_password']
postgresql_server_version = node['postgres_server_version']

app_db_user = node['app_db_user']
app_db_password= node['app_db_password']
app_db_name = node['app_db_name']

postgresql_server_install 'My Postgresql Server install' do
  action :install
end

postgresql_server_install 'Setup postgresql server' do
  version postgresql_server_version
  password root_password
  action :create
end
postgresql_access 'create_superuser' do
  comment 'Local postgres superuser access'
  access_type 'local'
  access_db 'all'
  access_user 'postgres'
  access_addr nil
  access_method 'ident'
end

postgresql_user 'Setup db user' do
  user app_db_user
  password app_db_password
  createdb true
  action :create
end


postgresql_access 'give access to service user' do
  comment 'sauron user access'
  access_type 'local'
  access_db 'all'
  access_user app_db_user
  access_addr nil
  access_method 'md5'
end


postgresql_database 'creating database' do
  database app_db_name 
  owner app_db_user
  locale 'C.UTF-8'
  action :create
end
