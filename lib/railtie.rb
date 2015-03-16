require 'rails'

module HTTPStatus

  # Inherit from Rails::Railtie, 
  # which gives access to config object, shared by all railties and the application.
  class Railtie < Rails::Railtie
    
  end
end