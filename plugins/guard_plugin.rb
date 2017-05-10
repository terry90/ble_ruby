class GuardPlugin < Plugin
  def run(ble)
    result = File.readlines(ENV['GUARD_RESULTS'])[0].strip
    color = result == 'success' ? '00FF00' : 'FF0000'
    ble.color(color) unless ble.current_color == color
  rescue
    $stderr.puts 'Please specify the full path of your Guardfile results in .env GUARD_RESULTS=xxx'
  end
end
