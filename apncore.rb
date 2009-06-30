require 'rubygems'
require 'json'

require 'bit-struct' # take it at http://redshift.sourceforge.net/bit-struct/

MAX_PAYLOAD_LEN = 256

class Hash

  def to_payload
    # Payload too long
    if (to_json.length > MAX_PAYLOAD_LEN)
      alert = self[:aps][:alert]
      self[:aps][:alert] = ''
      # can be chopped?
      if (to_json.length > MAX_PAYLOAD_LEN)
        raise 'Payload data to long, nothing to cut'
      else
        self[:aps][:alert] = alert
        while (self.to_json.length > MAX_PAYLOAD_LEN)
          self[:aps][:alert].chop!
        end
      end
    end
    to_json
  end

  def payloadLength
    to_payload.length
  end

end

module APNs4r

  class Notification < BitStruct
      # type      fieldname       size in bits  comment
      unsigned    :command,       8,            "Command (constant?)"
      unsigned    :tokenLength,   16,          "Token length(constant?)"
      unsigned    :deviceToken,   256,         "Device token"
      unsigned    :payloadLength, 16,          "Payload length"
      rest        :payload,                    "Body of message"

      note "     rest is application defined payload body"

      initial_value.command    = 0
      initial_value.tokenLength  = 32
  end

end
