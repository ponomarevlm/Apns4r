module APNs4r

  require 'socket'
  require 'openssl'

  $: << File.expand_path(File.dirname(__FILE__))+'/../' and require 'env/config' unless defined? OPTIONS

  class ApnsConnection

    @@host,@@port = nil, nil

    def ApnsConnection.host; @@host; end
    def ApnsConnection.port; @@port; end
    def ApnsConnection.host=(x); @@host = x; end
    def ApnsConnection.port=(x); @@port = x; end

    protected
    def self.connect
      ctx = OpenSSL::SSL::SSLContext.new()
      ctx.cert = OpenSSL::X509::Certificate.new(File::read(OPTIONS[:apns4r_cert_file]))
      ctx.key  = OpenSSL::PKey::RSA.new(File::read(OPTIONS[:apns4r_cert_key]))

      begin
        s = TCPSocket.new(@@host, @@port)
        @@ssl = OpenSSL::SSL::SSLSocket.new(s, ctx)
        @@ssl.connect # start SSL session
        @@ssl.sync_close = true # close underlying socket on SSLSocket#close
        return true
      rescue Errno::ETIMEDOUT
        retry
      end
    end

  end

end

