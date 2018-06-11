describe user('sauron') do
  it { should exist }
end

describe port(80)  do
  it { should_not be_listening }
end

describe systemd_service('puma') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end
