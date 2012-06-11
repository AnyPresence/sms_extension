source 'http://rubygems.org'

gem 'rails', '3.2.2'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'redis'
gem 'resque'
gem 'faraday'
gem 'twilio-ruby', '3.7.0'
gem "compass", :git => "git://github.com/chriseppstein/compass.git"
gem 'devise'
gem 'liquid'
gem 'haml'
gem 'hpricot'
gem 'dynamic_form'
gem "simple_form"
gem 'multi_json'
gem 'anypresence_extension', '0.0.1', :path => 'vendor/gems/anypresence_extension-0.0.1'



# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :development do
  gem 'heroku-rails', :git => 'git://github.com/sid137/heroku-rails.git'
end

group :test, :development do
  gem 'local-env'
  gem 'pg'
  gem 'rspec-rails', '~> 2.5'
  gem 'ruby-debug19'
end

group :production do
  gem 'pg'
end

group :test do
  gem 'factory_girl'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'webmock'
  gem 'vcr'
end