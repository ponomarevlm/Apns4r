$KCODE='u' and require 'jcode' if RUBY_VERSION =~ /1.8/
require 'rubygems'
require 'json'

MAX_PAYLOAD_LEN = 256

class Hash

  def to_payload
    # Payload too long
    if (to_json.length > MAX_PAYLOAD_LEN)
      alert = self[:aps][:alert]
      self[:aps][:alert] = ''
      # can be chopped?
      if (to_json.length > MAX_PAYLOAD_LEN)
        return nil
      else # inefficient way, but payload may be full of unicode-escaped chars, so...
        self[:aps][:alert] = alert
        while (self.to_json.length > MAX_PAYLOAD_LEN)
          self[:aps][:alert].chop!
        end
      end
    end
    to_json
  end

  def payload_length
    to_payload.length
  end

end

module APNs4r

  class Notification

    attr_accessor :token, :payload

    def initialize token, payload
      @token, @payload = token, payload
    end

    def Notification.create(token, payload)
      Notification.new token.kind_of?(String) ? token.delete(' ') : token.to_s(16) , payload.kind_of? Hash ? payload.to_payload : payload
    end

    def to_s
      [0, 32, @token, @payload.length, @payload ].pack("CnH*na*")
    end

    def Notification.parse bitstring
      command, tokenlen, token, payloadlen, payload = bitstring.unpack("CnH64na*")
      Notification.new(token, payload)
    end

  end

  class FeedbackServiceResponce

    attr_accessor :timestamp, :token

    def initialize bitstring
      @timestamp, tokenlen, @token = *bitstring.unpack('NnH*')
    end

  end

end
