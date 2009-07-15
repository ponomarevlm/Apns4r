$KCODE='u'
require 'jcode'
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
        return nil
      else
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

  class Notification < BitStruct
      # type      fieldname       size in bits  comment
      unsigned    :command,       8,            "Command (constant?)"
      unsigned    :token_length,   16,          "Token length(constant?)"
      unsigned    :device_token,   256,         "Device token"
      unsigned    :payload_length, 16,          "Payload length"
      rest        :payload,                    "Body of message"

      note "     rest is application defined payload body"

      initial_value.command    = 0
      initial_value.token_length  = 32
  end

end
