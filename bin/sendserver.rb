#!/usr/bin/env ruby
require 'rubygems'
require 'eventmachine'
require 'base64'

#add script's dir to require path
$: << File.expand_path(File.dirname(__FILE__))+'/../lib/'
require 'sender'
require 'apncore'

# properly close all connections and sokets
def stop
  APNs4r::Sender.closeConnection
  EventMachine::stop_server $server
  puts "#{Time.now.to_s} SendServer stopped"
  exit
end
Signal.trap("TERM") {stop}
Signal.trap("INT") {stop}


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
  if APNs4r::Sender.establishConnection :sandbox
    puts "#{Time.now.to_s} SendServer started"
    $server = EventMachine::start_server "0.0.0.0", 8801, SendServer
  else
    puts "#{Time.now.to_s} SendServer: failed to connect to APNs: timeout"
    exit 1
  end
}
