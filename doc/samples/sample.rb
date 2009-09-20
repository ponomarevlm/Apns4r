#sample client code


#add script's dir to require path
$: << File.expand_path(File.dirname(__FILE__))+'/../../lib/'
require 'apncore'
require 'sender'

payload = { :aps => {:alert => "Hey, dude!", :badge => 1}, :custom_data => "asd" }

# token is something like "e754daa9 XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX"
notification = APNs4r::Notification.create ARGV.shift, payload

APNs4r::Sender.establish_connection :sandbox
APNs4r::Sender.push notification
APNs4r::Sender.close_connection
