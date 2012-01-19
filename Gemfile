source 'http://rubygems.org'

gem 'rails', '3.1.3'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'


gem 'twilio-ruby'
gem 'devise'
gem 'liquid'
gem 'haml'
gem 'hpricot'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.1.5'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'dynamic_form'
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