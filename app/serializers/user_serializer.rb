class UserSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :given_name, :family_name, :locale, :picture, :email, :sub,:uuid, :wins, :losses, :hosted_games, :joined_games, :skill_rating, :total_games, :full_name
  
  attribute :persisted do |user, params|
    params[:persisted]
  end
  
end
