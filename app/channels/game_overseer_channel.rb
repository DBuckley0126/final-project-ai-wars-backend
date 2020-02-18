require_relative './concerns/game_overseer_channel_lobby_methods.rb'
require_relative './concerns/game_overseer_channel_game_methods.rb'

class GameOverseerChannel < ApplicationCable::Channel
  include GameOverseerChannelLobbyMethods
  include GameOverseerChannelGameMethods

end
