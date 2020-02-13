class UsersController < ApplicationController


  def create

    internal_audience_id = Rails.application.credentials.JWT_AUDIENCE_ID

    decoded_token_hash = JWT.decode(params["JWT"]["JWTToken"], nil, false)[0]
    
    if !decoded_token_hash["aud"] === internal_audience_id
      render json: {error: "Token does not match audience", status: 400}, status: 400
    end
    
    found_user = User.find_by(sub: decoded_token_hash["sub"])

    deconstructed_token = token_deconstructor(decoded_token_hash)

    if found_user
      found_user.update(deconstructed_token)
      api_token = JWT.encode(deconstructed_token, Rails.application.credentials.HMAC_SECRET, 'HS256')
      render json: {persisted: true, api_token: api_token}
    else
      new_user = User.create(deconstructed_token)
      if new_user
        api_token = JWT.encode(deconstructed_token, Rails.application.credentials.HMAC_SECRET, 'HS256')
        render json: {persisted: false, api_token: api_token}
      else
        render json: {error: "Unable to find or create user", status: 400}, status: 400
      end
    end
  end

  # def user_strong_params
  #   params.require(:user).permit(:sub, :given_name, :family_name, :locale, :picture, :email)
  # end
  def token_deconstructor(decoded_token_hash)
    return {
      given_name: decoded_token_hash["given_name"],
      family_name: decoded_token_hash["family_name"],
      locale: decoded_token_hash["locale"],
      picture: decoded_token_hash["picture"],
      email: decoded_token_hash["picture"],
      sub: decoded_token_hash["sub"],
      uuid: SecureRandom.urlsafe_base64
    }
  end
end

