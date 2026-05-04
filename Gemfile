source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.6'

gem 'rails', '~> 5.2.8', '>= 5.2.8.1'
gem 'sqlite3', '~> 1.4.0'
gem 'puma', '~> 3.11'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'whenever', require: false
gem 'kaminari', '~> 1.2'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 4.0'
  gem 'factory_bot_rails', '~> 5.2'
end

group :test do
  gem 'shoulda-matchers', '~> 4.0'
  gem 'database_cleaner-active_record', '~> 1.8'
  gem 'simplecov', '~> 0.18', require: false
end

group :development do
  gem 'listen', '~> 3.1.5'
  gem 'ffi', '~> 1.15.0'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
