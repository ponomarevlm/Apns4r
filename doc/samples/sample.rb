#sample client code


#add script's dir to require path
$: << File.expand_path(File.dirname(__FILE__))
require 'apncore'
require 'sender'

p = { :aps => {:alert => "Hey, dude!"}, :data => "asd" }

notification = APNs4r::Notification.new :payload => p.to_payload , :payloadLength => p.payloadLength, :deviceToken => ARGV.shift.hex # "e754daa9 XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX".delete(' ').hex

APNs4r::Sender.establishConnection :sandbox
APNs4r::Sender.send notification
APNs4r::Sender.closeConnection

