source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.3'

gem 'pg', '~> 1.2.3'
gem 'rails', '~> 6.0.3', '>= 6.0.3.1'
gem 'puma', '~> 4.1'
gem 'sass-rails', '>= 6'
gem 'webpacker', '~> 4.0'
gem 'jbuilder', '~> 2.7'
gem 'image_processing', '~> 1.2'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'apitome', '~> 0.3'

group :development, :test do
  gem 'pry-byebug'
  gem 'rspec_api_documentation', '~> 6.1.0'
  gem 'factory_bot_rails', '~> 5.2.0'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'rspec-rails', '~> 4.0.1'
  gem 'capybara', '>= 2.15'
  gem 'timecop', '~> 0.9'
end
