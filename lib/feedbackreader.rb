module APNs4r

  require 'socket'
  require 'openssl'
  require 'timeout'
  $: << File.expand_path(File.dirname(__FILE__))
  require 'apnsconnection'
  require 'apncore'

  class FeedbackReader < ApnsConnection
    @@host = 'feedback.sandbox.push.apple.com'
    @@port = 2196

    def self.read environment
      @@environment = environment
      @@host = ( environment.to_sym == :sandbox ? 'feedback.sandbox.push.apple.com' : 'feedback.push.apple.com' )
      self.connect
     
      #while responce = FeedbackServiceResponce.new(@@ssl.gets)
        #puts responce
      #end
      while s = @@ssl.gets
        puts s
      end
      @@ssl.close
    end

  end

end

APNs4r::FeedbackReader.read :sandbox
