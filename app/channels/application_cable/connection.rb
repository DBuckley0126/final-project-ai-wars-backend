module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :user
    def connect
      self.user = find_verified_user
    end

    private

    def find_verified_user
      begin
        header_array = request.headers[:HTTP_SEC_WEBSOCKET_PROTOCOL].split(',')
        token = header_array[header_array.length-1]
        decoded_token = JWT.decode token.strip, Rails.application.credentials.HMAC_SECRET, true, { :algorithm => 'HS256' }

        if (user = User.find_by(uuid:(decoded_token[0])['uuid']))
          user
        else
          puts `Unable to find user with uuid #{(decoded_token[0])['uuid']} `
          reject_unauthorized_connection
        end
      rescue
        puts "Unable to decode request header"
        reject_unauthorized_connection
      end
    end

  end
end
