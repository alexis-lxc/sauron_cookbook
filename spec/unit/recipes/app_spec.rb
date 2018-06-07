require 'spec_helper'
require_relative '../../../libraries/github'

describe 'sauron_cookbook::app' do

  before(:each) do
    @runner = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04') do |node|
      node.automatic['app_name'] = 'my_app'
    end
    allow_any_instance_of(Chef::HTTP).to receive(:get).and_return("{\"tag_name\":\"0.0.1-pre-alpha\"}")
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
    it 'installs packages software-properties-common, ruby2.4, ruby2.4-dev, nodejs, build-essential, patch, ruby-dev, zlib1g-dev, liblzma-dev, libpq-dev, ruby-switch' do
      chef_run = @runner.converge(described_recipe)
      expect(chef_run).to install_package(%w(software-properties-common ruby2.4 ruby2.4-dev nodejs build-essential patch ruby-dev
                                          zlib1g-dev liblzma-dev libpq-dev ruby-switch))
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
      expect(chef_run).to create_group('my_app')
    end
  end

  context 'user' do
    it 'creates a user with attributes' do
      chef_run = @runner.converge(described_recipe)
      expect(chef_run).to create_user('my_app').with(comment: 'sauron user', uid: 2000, gid: 2000, home: '/opt/my_app', manage_home: true, shell: '/bin/bash')
    end
  end

  context 'directory' do
    it 'creates a release dir /opt/my_app/0.0.1-pre-alpha' do
      chef_run = @runner.converge(described_recipe)
      expect(chef_run).to create_directory('/opt/my_app/0.0.1-pre-alpha').with(
        owner:     'my_app',
        recursive: true,
        group:     'my_app'
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

    it 'creates a run dir /var/run/my_app ' do
      chef_run = @runner.converge(described_recipe)
      expect(chef_run).to create_directory('/var/run/my_app').with(
        owner:     'my_app',
        recursive: true,
        group:     'my_app',
        mode:      0755
      )
    end
  end

  context 'When all attributes are default, on Ubuntu 16.04' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04') do |node|
        node.automatic['app_name'] = 'my_app'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
