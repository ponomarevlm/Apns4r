module APNs4r

  class FeedbackReader < ApnsConnection

    attr_accessor :host, :port
    def initialize host = OPTIONS[:apns4r_feedback_host], port = OPTIONS[:apns4r_feedback_port]
      @host, @port = host, port
    end

    def read
      @ssl ||= connect

      records ||= []
      while record = @@ssl.read(38)
        records << record.unpack('NnH*')
      end
      @@ssl.close
      records
    end

  end

end
