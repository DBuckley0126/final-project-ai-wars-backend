class UserSerializer
  include FastJsonapi::ObjectSerializer
  has_many :created_games
  has_many :joined_games
  has_many :spawners
  attributes :given_name, :family_name, :locale, :picture, :email, :sub
  
  attribute :persisted do |user, params|
    params[:persisted]
  end
  
end
