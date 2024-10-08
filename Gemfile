# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.3.4'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 7.1.4'

# Use sqlite3 as the database for Active Record
gem 'sqlite3', '>= 1.4'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 5.0'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem 'jbuilder'

# Use Redis adapter to run Action Cable in production
# gem 'redis', '>= 4.0.1'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem 'kredis'

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem 'bcrypt', '~> 3.1.7'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem 'image_processing', '~> 1.2'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
# gem 'rack-cors'

gem 'parser', '3.3.4'
gem 'active_model_serializers', '~> 0.10.14'
gem 'rswag', '~> 2.14'
gem 'rubocop', '~> 1.66', '>= 1.66.1'
gem 'rubocop-rails', '~> 2.26', '>= 2.26.1'
gem 'jwt', '~> 2.8', '>= 2.8.2'
gem 'aws-sdk-s3', '~> 1.163'
gem 'kaminari', '~> 1.2', '>= 1.2.2'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri windows]
  gem 'rspec-rails', '~> 7.0', '>= 7.0.1'
  gem 'factory_bot_rails', '~> 6.4', '>= 6.4.3'
  gem 'yard', '~> 0.9.37'
  gem 'shoulda-matchers', '~> 6.4'
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem 'spring'
  gem 'solargraph', '~> 0.50.0'
  gem 'solargraph-rails', '~> 1.1'
end
