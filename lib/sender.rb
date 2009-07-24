module APNs4r

  require 'socket'
  require 'openssl'
  require 'timeout'
  $: << File.expand_path(File.dirname(__FILE__))
  require 'apnsconnection'

  class Sender

    def self.establishConnection environment
      @@environment ||= environment
      return true if @@ssl
      host = ( environment.to_sym == :sandbox ? 'gateway.sandbox.push.apple.com' : 'gateway.push.apple.com' )
      port = 2195
      self.connect(host, port)
    end

    def self.send notification
      begin
        @@ssl.write notification
      rescue OpenSSL::SSL::SSLError, Errno::EPIPE
        self.establishConnection @@environment
        @@ssl.write notification
      end
    end

    def self.closeConnection
      @@ssl.close
      @@ssl = nil
    end

  end

end

