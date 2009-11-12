$KCODE='u' and require 'jcode' if RUBY_VERSION =~ /1.8/
require 'json'

class Hash
  MAX_PAYLOAD_LEN = 256

  # Converts hash into JSON String.
  # When payload is too long but can be chopped, tries to cut self.[:aps][:alert].
  # If payload still don't fit Apple's restrictions, returns nil
  #
  # @return [String, nil] the object converted into JSON or nil.
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

  # Invokes {Hash#to_payload} and returns it's length
  # @return [Fixnum, nil] length of object converted into JSON or nil.
  def payload_length
    p = to_payload
    p ? p.length : nil
  end

end

module APNs4r

  class Notification

    def initialize token, payload
      @token, @payload = token, payload
    end

    # Creates new notification with given token and payload
    # @param [String, Fixnum] token APNs token of device to notify
    # @param [Hash, String] payload attached payload
    # @example
    # APNs4r::Notification.create 'e754dXXXX...', { :aps => {:alert => "Hey, dude!", :badge => 1}, :custom_data => "asd" }
    def Notification.create(token, payload)
      Notification.new token.kind_of?(String) ? token.delete(' ') : token.to_s(16) , payload.kind_of?(Hash) ? payload.to_payload : payload
    end

    # Converts to binary string wich can be writen directly into socket
    # @return [String] binary string representation
    def to_s
      [0, 32, @token, @payload.length, @payload ].pack("CnH*na*")
    end

    # Counterpart of {Notification#to_s} - parses from binary string
    # @param [String] bitstring string to parse
    # @return [Notification] parsed Notification object
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
