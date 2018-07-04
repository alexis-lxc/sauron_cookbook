describe user('sauron') do
  it { should exist }
end

describe port(3100)  do
  it { should be_listening }
end

describe systemd_service('puma') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe systemd_service('redis') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe systemd_service('sidekiq') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe systemd_service('postgresql') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe file('/opt/sauron/.config/lxc/client.crt') do
  it { should exist }
end

describe file('/opt/sauron/.config/lxc/client.key') do
  it { should exist }
end
