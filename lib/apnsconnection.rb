module APNs4r

  require 'socket'
  require 'openssl'
  require 'timeout'

  class ApnsConnection

    @@host,@@port = nil, nil

    def ApnsConnection.host; @@host; end
    def ApnsConnection.port; @@port; end
    def ApnsConnection.host=(x); @@host = x; end
    def ApnsConnection.port=(x); @@port = x; end

    protected
    def self.connect
      certdir   = File.expand_path(File.dirname(__FILE__))+'/../cert'
      cert_file = File.join(certdir , 'apns_developer_identity.cer')
      key_file  = File.join(certdir , 'apns_developer_private_key.pem')

      ctx = OpenSSL::SSL::SSLContext.new()
      if cert_file && key_file
        ctx.cert = OpenSSL::X509::Certificate.new(File::read(cert_file))
        ctx.key  = OpenSSL::PKey::RSA.new(File::read(key_file))
      end

      s = TCPSocket.new(@@host, @@port)
      begin
        timeout(30) do
          @@ssl = OpenSSL::SSL::SSLSocket.new(s, ctx)
          @@ssl.connect # start SSL session
          @@ssl.sync_close = true # close underlying socket on SSLSocket#close
          return true
        end
      rescue TimeoutError
        return false
      end
    end

  end

end

