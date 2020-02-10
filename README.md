# final-project-ai-wars-backend
A Flatiron Javascript project — Gryo is a javascript game which runs simultaneously on your phone and desktop, using the mobile device gyroscope sensors as the desktop game input for control of a spaceship in a zero-gravity environment.

The backend of this project  uses the Ruby on Rails framework toegther with th ActionCable technology that Rails introduced to handle the WebSocket functionality required for this project.

# Ruby Version
2.6.5

## Getting Started

Clone or download the repository to your local machine and run the following terminal commands inside of the directory:  

bundle install  
rails db:migrate


run 'rails s' in terminal to begin local hosting of Rails backend.  


## Built With

* [Rails](https://github.com/rails/rails) - Used for the web development framework  
* [ActionCable](https://guides.rubyonrails.org/action_cable_overview.html) - Used to provide WebSocket functionality
* [fast_jsonapi](https://github.com/omniauth/omniauth) - Used to for active record serialization

## Versioning

This application uses Semantic Versioning.

## Authors

* **Danny Buckley** - *Initial work* - [Me](https://github.com/DBuckley0126)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
