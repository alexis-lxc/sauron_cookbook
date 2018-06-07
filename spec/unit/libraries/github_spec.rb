require 'spec_helper'
require_relative '../../../libraries/github'

describe 'github' do

  context 'release_name' do
    let(:repo_name){ 'alexis-lxc/sauron' }

    context 'latest release contains tag_name' do
      it 'returns the tag_name' do
        allow_any_instance_of(Chef::HTTP).to receive(:get).and_return("{\"tag_name\":\"abc\"}")

        expect(Github.release_name(repo_name)).to eq('abc')
      end
    end

    context 'latest release doesnot contain tag_name' do
      it 'returns empty string' do
        allow_any_instance_of(Chef::HTTP).to receive(:get).and_return("{\"some_name\":\"abc\"}")

        expect(Github.release_name(repo_name)).to eq('')
      end
    end
  end

  context 'release_file' do
    let(:repo_name){ 'alexis-lxc/sauron' }

    context 'latest release contains assets' do
      it 'returns the download tar url' do
        allow_any_instance_of(Chef::HTTP).to receive(:get).and_return("{\"assets\":[{\"browser_download_url\":\"www.github.com/sauron.tar\"}]}")

        expect(Github.release_file(repo_name)).to eq('www.github.com/sauron.tar')
      end
    end

    context 'latest release doesnot contain assets' do
      it 'returns empty string' do
        allow_any_instance_of(Chef::HTTP).to receive(:get).and_return("{\"noassets\":[{\"browser_download_url\":\"www.github.com/sauron.tar\"}]}")

        expect(Github.release_file(repo_name)).to eq('')
      end
    end
  end

end
