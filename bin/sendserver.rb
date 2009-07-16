#!/usr/bin/env ruby

#add script's dir to require path
$: << File.expand_path(File.dirname(__FILE__))+'/../lib/'
['rubygems', 'eventmachine', 'base64', 'sender', 'apncore', 'config'].each{|lib| require lib}

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
    # pinging our device to avoid socket close by APNs
    EventMachine::add_periodic_timer( 300 ) do
      p = { :ping => Time.now.to_i.to_s }
      notification = APNs4r::Notification.new :payload => p.to_payload , \
        :payload_length => p.payload_length, :device_token => OPTIONS[:ping_device_token]
      APNs4r::Sender.send notification
    end
    puts "#{Time.now.to_s} SendServer started"
    $server = EventMachine::start_server OPTIONS[:sendserver_ip], OPTIONS[:sendserver_port], SendServer
  else
    puts "#{Time.now.to_s} SendServer: failed to connect to APNs: timeout"
    exit 1
  end
}
