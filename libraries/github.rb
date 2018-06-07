class Github
  def self.release_file(repo)
    url = "https://api.github.com/repos/#{repo}/releases/latest"
    latest_release = JSON.parse(Chef::HTTP.new(url).get(''))
    if latest_release.key?('assets')
      return latest_release['assets'].first['browser_download_url']
    else
      return ''
    end
  end

  def self.release_name(repo)
    url = "https://api.github.com/repos/#{repo}/releases/latest"
    latest_release = JSON.parse(Chef::HTTP.new(url).get(''))
    if latest_release.key?('tag_name')
      return latest_release['tag_name']
    else
      return ''
    end
  end
end
