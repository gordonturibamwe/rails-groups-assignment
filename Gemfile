source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }
ruby "3.0.0"
gem "rails", "~> 7.0.3" # Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "pg", "~> 1.1" # Use postgresql as the database for Active Record
gem "puma", "~> 5.0" # Use the Puma web server [https://github.com/puma/puma]
gem "jbuilder" # Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ] # Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "bootsnap", require: false # Bootsnap is a library that plugs into Ruby, with optional support for YAML, to optimize and cache expensive computations.
gem 'jwt' # web tokens
gem "rack-cors" # Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem "bcrypt", "~> 3.1.7" # password encryption
gem 'twilio-ruby' # For sms
gem "redis", "~> 4.0"
gem "image_processing", "~> 1.2"


group :development, :test do # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem 'rspec-rails' # For testing
  gem 'rb-fsevent' # For testing
  gem 'guard-rspec', require: false # For automatic testing ~> `bundle exec guard` or `guard`
  gem 'rails-controller-testing'
  gem 'shoulda-matchers'
end
group :development do # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
  gem 'faker', :git => 'https://github.com/faker-ruby/faker.git', :branch => 'master'
end

# For Documentation
# gem install bundler jekyll ~> For Documentation



# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"
# Reduces boot times through caching; required in config/boot.rb
# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"
# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"
# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

