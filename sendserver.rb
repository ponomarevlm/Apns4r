#!/usr/bin/env ruby
require 'rubygems'
require 'eventmachine'
require 'base64'

#add script's dir to require path
$: << File.expand_path(File.dirname(__FILE__))
require 'sender'
require 'apncore'

# properly close all connections and sokets
Signal.trap("TERM") do
  APNs4r::Sender.closeConnection
  EventMachine::stop_server $server
  puts "#{Time.now.to_s} SendServer stopped"
  exit
end


module SendServer
  def post_init
    puts "-- #{Time.now.to_s} -- Incoming connection"
  end

  def receive_data data
    # TODO store notifications for later batch transmission
    # only when some scaling needed
    notification = Marshal.load( Base64.decode64(data))
    APNs4r::Sender.send notification
    puts "#{Time.now.to_s} #{notification.payload}"
  end

  def unbind
    puts "-- #{Time.now.to_s} -- Connection closed"
  end
end

EventMachine::run {
  puts "#{Time.now.to_s} SendServer started"
  APNs4r::Sender.establishConnection :sandbox
  $server = EventMachine::start_server "0.0.0.0", 8801, SendServer
}
