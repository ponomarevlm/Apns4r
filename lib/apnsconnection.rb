module APNs4r

  require 'socket'
  require 'openssl'

  class ApnsConnection

    protected
    def connect host, port, overrides = {}
      ctx = OpenSSL::SSL::SSLContext.new()
      ctx.cert = OpenSSL::X509::Certificate.new(File::read(overrides[:apns4r_cert_file] || OPTIONS[:apns4r_cert_file]))
      ctx.key  = OpenSSL::PKey::RSA.new(File::read(overrides[:apns4r_cert_key] || OPTIONS[:apns4r_cert_key]))

      begin
        s = TCPSocket.new(host, port)
        ssl = OpenSSL::SSL::SSLSocket.new(s, ctx)
        ssl.connect # start SSL session
        ssl.sync_close = true # close underlying socket on SSLSocket#close
        ssl
      rescue Errno::ETIMEDOUT
        nil
      end
    end

  end

end

