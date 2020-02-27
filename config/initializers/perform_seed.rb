Game.destroy_all
Unit.destroy_all
Spawner.destroy_all 
Turn.destroy_all

Game.create(uuid: "a9bb9988-3615-9d2a-8358-625f80a21d49", host_user_id: 3, host_user_type: User, host_user_colour: "#3ca832", join_user_colour: "#3ca832")