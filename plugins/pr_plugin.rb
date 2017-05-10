require 'json'
require 'net/http'

class PRPlugin < Plugin
  BASE_URL = 'https://api.github.com'
  
  def run(ble = BLE.instance)
    nb_pr = 0
    @repos ||= read_repos
    @repos.each do |repo|
      nb_pr += pr_nb_for(repo)
    end
    nb_pr > 0 ? ble.pulse(ble.current_color, [5 - nb_pr, 2].max) : ble.halt_effect
  end
  
  private

  def pr_nb_for(repo)
    uri = URI("#{BASE_URL}/repos/#{repo}/pulls")

    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "token #{ENV['GITHUB_TOKEN']}"

    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = true
    res = http.request(req)
    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      return JSON.parse(res.body).count
    else
      0
    end
  end
  
  def read_repos
    begin
      path = File.join(File.dirname(__FILE__), '../pr_repos')
      content = File.readlines(path)
      repos = content.map(&:strip).reject(&:empty?)
      return repos
    rescue Errno::ENOENT => e
      puts 'Please create the file pr_repos'
      puts 'Add one repo per line'
      puts 'Must be formatted like this: owner/repo'
      repos = []
    end
  end
end
