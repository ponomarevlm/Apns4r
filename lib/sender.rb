module APNs4r

  require 'socket'
  require 'openssl'
  require 'timeout'
  $: << File.expand_path(File.dirname(__FILE__))
  require 'apnsconnection'

  class Sender < ApnsConnection

    def self.establish_connection environment
      @@environment ||= environment
      @@host ||= ( environment.to_sym == :sandbox ? 'gateway.sandbox.push.apple.com' : 'gateway.push.apple.com' )
      @@port ||= 2195
      self.connect
      return true if @@ssl
    end

    def self.push notification
      begin
        @@ssl.write notification
      rescue OpenSSL::SSL::SSLError, Errno::EPIPE
        self.establish_connection @@environment
        @@ssl.write notification
      end
    end

    def self.close_connection
      @@ssl.close
      @@ssl = nil
    end

  end

end

