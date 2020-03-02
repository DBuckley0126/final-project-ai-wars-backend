# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Game.destroy_all
# Unit.destroy_all
# Spawner.destroy_all 
# Turn.destroy_all

# Game.create(uuid: "a9bb9988-3615-9d2a-8358-625f80a21d49", host_user_id: 3, host_user_type: User, host_user_colour: "#3ca832", join_user_colour: "#3ca832")

computer_user = User.find_by(sub: "backend|5e45d67f1ba0ebb439e98")

if computer_user
  User.destroy(computer_user.id)
end

User.create(given_name: "Game", family_name: "Controller", locale: "en-GB", sub: "backend|5e45d67f1ba0ebb439e98", uuid: "F04gDzK3LVhzPJCpzKqIWw")

