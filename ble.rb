require 'open3'
require 'singleton'

class BLE
  include Singleton

  attr_reader :current_color

  RECONNECT_STR = 'Disconnected'.freeze
  CONNECT_DELAY = 5
  PRE_CMDS = {
    effect: 'char-write-cmd 0x0023',
    color:  'char-write-cmd 0x0025'
  }.freeze

  def start(uid)
    raise 'Command already running' if @cmd
    @cmd = "gatttool -b #{uid} -I"
    @current_color = '000000'

    stdin, stdout, stderr = Open3.popen3(@cmd)
    @stdin = stdin

    listen_output(stdout)
    listen_output(stderr, 'ERR: ')
  end

  def connect
    input('connect')
    sleep CONNECT_DELAY
  end

  def disconnect
    input('disconnect')
    sleep CONNECT_DELAY
  end

  def halt_effect
    no_effect = "#{PRE_CMDS[:effect]} 00#{@current_color}FFFF00FF"
    input(no_effect) unless @current_effect == no_effect
    @current_effect = no_effect
  end

  def pulse(color, delay = 4)
    @current_color = validate_color(color)
    effect = "#{PRE_CMDS[:effect]} 00#{@current_color}01FF#{'%02d' % delay}FF"
    input(effect) unless effect == @current_effect
    @current_effect = effect
  end

  def color(color = @current_color)
    @current_color = validate_color(color)
    input("#{PRE_CMDS[:color]} 00#{@current_color}")
  end

  private

  def validate_color(color)
    color.delete!('#')
    if color.length != 6
      $stderr.puts('Color must be formatted like this: #F0F1FA')
      color = '200000'
    end
    color
  end

  def input(payload)
    @stdin.puts payload
  end

  def listen_output(out, key = '')
    Thread.new do
      until (line = out.gets).nil?
        puts "#{key}#{line}"
        if line =~ /#{RECONNECT_STR}/
          puts('Reconnecting...') && connect
        end
      end
    end
  end
end
