#!/usr/bin/env ruby
require 'dotenv'

require_relative 'ble.rb'
require_relative 'plugin.rb'

Dir['plugins/*.rb'].each { |file| require File.join(File.dirname(__FILE__), file) }

Thread.abort_on_exception = true
Dotenv.load!

puts "Registered plugins: #{Plugin.each_c(&:to_s).join(', ')}"

UID = '59:0E:4B:18:AC:E6'.freeze

ble = BLE.instance
ble.start(UID)
ble.connect

Plugin.each do |plugin|
  Thread.new do
    loop do
      sleep(plugin.delay)
      begin
        plugin.run(ble)
      rescue
        puts "#{plugin.class} failed to run"
      end
    end
  end
end

at_exit { ble.disconnect }

sleep
