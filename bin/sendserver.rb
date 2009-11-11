#!/usr/bin/env ruby

#add script's dir to require path
$: << File.expand_path(File.dirname(__FILE__))+'/../'
['eventmachine', 'logger', 'lib/apns4r'].each{|lib| require lib}

$logger = Logger.new("#{File.expand_path(File.dirname(__FILE__))}/../log/sendserver.log", 10, 1024000)
# properly close all connections and sokets
def stop
  APNs4r::Sender.close_connection
  EventMachine::stop_server $server
  $logger.info "SendServer stopped"
  exit
end
Signal.trap("TERM") {stop}
Signal.trap("INT") {stop}


module SendServer
  def post_init
    $logger.info "Incoming connection"
    @sender = APNs4r::Sender.new
  end

  def receive_data data
    # TODO store notifications for later batch transmission
    # only when some scaling needed
    data = data.chomp
    @sender.push data
    $logger.info Notification.parse(data).payload
  end

  def unbind
    $logger.info "Connection closed"
  end
end

EventMachine::run {
  if APNs4r::Sender.establish_connection :sandbox
    # pinging our device to avoid socket close by APNs
    EventMachine::add_periodic_timer( 300 ) do
      payload = { :ping => Time.now.to_i.to_s }
      notification = APNs4r::Notification.create OPTIONS[:apns4r_ping_device_token], payload
      APNs4r::Sender.push notification
    end
    $logger.info "SendServer started"
    $server = EventMachine::start_server OPTIONS[:apns4r_sendserver_host], OPTIONS[:apns4r_sendserver_port], SendServer
  else
    $logger.error "SendServer: failed to connect to APNs: timeout"
    exit 1
  end
}
