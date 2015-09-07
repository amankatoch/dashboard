source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.7'
# Use sqlite3 as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development
gem 'puma'
gem 'houston'
gem 'resque'
gem 'resque_mailer'
gem 'figaro'
gem 'connection_pool'
gem 'cloudinary'
gem 'activerecord-postgres-earthdistance'
gem 'stripe'
gem 'koala', '~> 1.11.0rc'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
group :development do
  gem 'capistrano',         require: false
  gem 'capistrano-rails',   require: false
  gem 'capistrano-rvm',   require: false
  gem 'capistrano3-puma',   require: false
  gem 'capistrano-bundler', require: false
  gem "capistrano-resque", "~> 0.2.1", require: false
  gem 'capistrano3-nginx', '~> 2.0'
end

group :development, :test do
  gem 'rspec-rails', '~> 3.0.0'
  gem 'rubocop', require: false
  gem 'factory_girl_rails'
  gem 'spring-commands-rspec'
  gem 'faker'
end

group :test do
  gem 'vcr'
  gem 'webmock'
  gem 'stripe-ruby-mock', '~> 2.1.0', :require => 'stripe_mock'
end

# Use debugger
# gem 'debugger', group: [:development, :test]

gem 'devise'
gem 'apipie-rails'
gem 'inherited_resources', '1.5.1'
gem 'active_model_serializers'
gem 'cancancan', '~> 1.9'
gem 'activeadmin', github: 'activeadmin'
gem 'ransack'
