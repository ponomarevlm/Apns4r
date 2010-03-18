module APNs4r

  class Sender < ApnsConnection

    attr_accessor :host, :port

    # Creates new {Sender} object with given host and port
    # 
    # Accepts params in 2 ways, either as 2 strings :
    # @param [String] host default to APNs sandbox
    # @param [Fixnum] port don't think it can change, just in case
    #
    # or as a Hash of optional arguments:
    # :host => [String] host default to APNs sandbox
    # :port => [Fixnum] port don't think it can change, just in case
    # :apns4r_cert_file => [String] path to cert file (used to support multiple iphone applications from one server) 
    # :apns4r_cert_key => [String] path to cert key (as above)
    def initialize *args
      
      if args[0].is_a? Hash
        options = args[0]
        @host = options.delete(:host) || OPTIONS[:apns4r_push_host]
        @port = options.delete(:port) || OPTIONS[:apns4r_push_port]
        
        @ssl ||= connect(@host, @port, options)
      else
        @host = args[0] || OPTIONS[:apns4r_push_host]
        @port = args[1] || OPTIONS[:apns4r_push_port]

        @ssl ||= connect(@host, @port)
      end
      self
    end

    # sends {Notification} object to Apple's server
    # @param [Notification] notification notification to send
    # @example
    # n = APNs4r::Notification.create 'e754dXXXX...', { :aps => {:alert => "Hey, dude!", :badge => 1}, :custom_data => "asd" }
    # sender = APNs4r::Sender.new.push n
    def push notification
      delay = 2
      begin
        @ssl.write notification.to_s
      rescue OpenSSL::SSL::SSLError, Errno::EPIPE
        sleep delay
        @ssl = connect(@host, @port)
        delay*=2 and retry if delay < 60
        raise Timeout::Error
      end
    end

    def close_connection
      @ssl.close
      @ssl = nil
    end

  end

end

