module APNs4r

  $: << File.expand_path(File.dirname(__FILE__))
  require 'apnsconnection'
  require 'apncore'

  class FeedbackReader < ApnsConnection

    def self.read environment
      unless defined? @@ssl
        @@environment = environment
        @@host ||= ( environment.to_sym == :sandbox ? 'feedback.sandbox.push.apple.com' : 'feedback.push.apple.com' )
        @@port ||= 2196
        self.connect
      end

      records ||= []
      while record = @@ssl.read(38)
        records << record.unpack('NnH*')
      end
      @@ssl.close
      records
    end

  end

end
