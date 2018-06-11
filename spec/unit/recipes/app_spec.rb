require 'spec_helper'
require_relative '../../../libraries/github'

describe 'sauron_cookbook::app' do

  before(:each) do
    @runner = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04') do |node|
      node.automatic['app_name'] = 'sauron'
      node.automatic['sauron_script_location'] = '/opt/sauron/sauron_start.sh'
      node.automatic['command_name'] = 'puma -C /etc/puma/sauron.rb'
      node.automatic['environment_variables'] =  {
                       rails_env: 'production',
                       DB_HOST: 'localhost',
                       DB_NAME: 'sauron',
                       DB_USER: 'sauron',
                       DB_PASSWORD: 'test123',
                       DB_POOL: 10
                     }
    end
    allow_any_instance_of(Chef::HTTP).to receive(:get).and_return("{\"tag_name\":\"0.0.1-pre-alpha\"}")
  end

  it 'converges successfully' do
    chef_run = @runner.converge(described_recipe)
    expect { chef_run }.to_not raise_error
  end
  context 'apt_repository' do
    it 'should add brightbox/ruby-ng in apt-rep' do
      chef_run = @runner.converge(described_recipe)
      expect(chef_run).to add_apt_repository('brightbox-ruby')
    end
  end

  context 'apt_update' do
    it 'updates apt repo' do
      chef_run = @runner.converge(described_recipe)
      expect(chef_run).to update_apt_update('update')
    end
  end

  context 'package install' do
    it 'installs packages software-properties-common, ruby2.5, ruby2.5-dev, nodejs, build-essential, patch, ruby-dev, zlib1g-dev, liblzma-dev, libpq-dev' do
      chef_run = @runner.converge(described_recipe)
      expect(chef_run).to install_package(%w(software-properties-common ruby2.5 ruby2.5-dev nodejs build-essential patch ruby-dev
                                          zlib1g-dev liblzma-dev libpq-dev))
    end
  end

  context 'gem_package' do
    it 'installs gem bundler' do
      chef_run = @runner.converge(described_recipe)
      expect(chef_run).to install_gem_package('bundler')
    end
  end

  context 'group' do
    it 'creates a group for the app_name passed' do
      chef_run = @runner.converge(described_recipe)
      expect(chef_run).to create_group('sauron')
    end
  end

  context 'user' do
    it 'creates a user with attributes' do
      chef_run = @runner.converge(described_recipe)
      expect(chef_run).to create_user('sauron').with(comment: 'sauron user', uid: 2000, gid: 2000, home: '/opt/sauron', manage_home: true, shell: '/bin/bash')
    end
  end

  context 'directory' do
    it 'creates a release dir /opt/sauron/0.0.1-pre-alpha' do
      chef_run = @runner.converge(described_recipe)
      expect(chef_run).to create_directory('/opt/sauron/0.0.1-pre-alpha').with(
        owner:     'sauron',
        recursive: true,
        group:     'sauron'
      )
    end

    it 'creates a /etc/puma directory' do
      chef_run = @runner.converge(described_recipe)
      expect(chef_run).to create_directory('/etc/puma').with(
        owner:     'root',
        recursive: true,
        group:     'root'
      )
    end

    it 'creates a run dir /var/run/sauron ' do
      chef_run = @runner.converge(described_recipe)
      expect(chef_run).to create_directory('/var/run/sauron').with(
        owner:     'sauron',
        recursive: true,
        group:     'sauron',
        mode:      0755
      )
    end
  end

  context 'tar extract' do
    it 'creates a source directory to extract to if one doesn\'t exist.' do
      chef_run = @runner.converge(described_recipe)
      expect(chef_run).to create_directory('/opt/sauron/0.0.1-pre-alpha').with(
                            owner:     'sauron',
                            recursive: true,
                            group:     'sauron')
    end
  end

  context 'file' do
    it 'should create file with environment variables' do
      chef_run = @runner.converge(described_recipe)
      expect(chef_run).to render_file('/etc/default/sauron.conf').with_content(/^DB_USER/)
      expect(chef_run).to render_file('/etc/default/sauron.conf').with_content(/^DB_NAME/)
      expect(chef_run).to render_file('/etc/default/sauron.conf').with_content(/^DB_PASSWOR/)
      expect(chef_run).to render_file('/etc/default/sauron.conf').with_content(/^DB_POOL/)
    end
  end
end
