require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MessengerApi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    config.api_only = true
    config.debug_exception_response_format = :api
    config.time_zone = 'America/Denver'

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.generators do |g|
      g.orm :active_record
      g.test_framework :rspec
      g.template_engine nil
      g.assets false
      g.helper false
      g.integration_tool :capybara
      g.system_tests :rspec
      g.stylesheets false
    end
  end
end
