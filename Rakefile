# Inspired from
# https://gist.github.com/1576435

require 'rubygems' if RUBY_VERSION < '1.9'
require 'bundler' # gem requires
require 'fileutils'
require 'rake'
require 'rake/sprocketstask'

PROJECT_ROOT = File.expand_path(File.dirname(__FILE__))
require './application/settings'
require './application/core_extensions/sprockets'

Bundler.require

%w(./application/settings ./application/core ./application/assets).each do |requirement|
  require requirement
end


# The default, if you just run `rake` in this directory, will list all the available tasks
task :default do
  puts "All available rake tasks"
  system('rake -T')
end

desc "Start Unicorn in development mode and get memcached running"
task :s do
  system("bundle exec foreman start")
end

desc "Precompile assets"
namespace :assets do
  
  task :precompile do
    puts "Precompiling assets...\n"
    configure_sprockets :precompile => true
  end

end
