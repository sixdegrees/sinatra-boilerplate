# The default, if you just run `rake` in this directory, will list all the available tasks
task :default do
  puts "All available rake tasks"
  system('rake -T')
end

desc "Start Unicorn in development mode and get memcached running"
task :s do
  system("bundle exec foreman start")
end





# Inspired from
# https://gist.github.com/1576435

require 'rubygems'
require 'bundler'
require 'fileutils'

# Require gems from Gemfile
Bundler.require

require 'rake'
require 'rake/sprocketstask'

require './config/config'
require './config/sprockets'


SPROCKETS_ENV.css_compressor = Sprockets::Sass::Compressor.new
SPROCKETS_ENV.js_compressor  = Uglifier.new(mangle: true)


desc "Precompile assets"
namespace :assets do
  
  task :precompile => [:dynamic, :static] do
    puts "Precompiling assets...\n"
  end

  task :dynamic do

    s = Sprockets::StaticCompiler.new(
      SPROCKETS_ENV,
      SPROCKETS_OUTPUT,
      SPROCKETS_BUNDLES, 
      :manifest_path => SPROCKETS_MANIFEST,
      :digest => SPROCKETS_DIGEST,
      :manifest => SPROCKETS_DIGEST.nil?
    )
    s.compile

  end

  task :list do 
    SPROCKETS_ENV.each_logical_path do |lp|
      puts lp
    end
  end
  task :static do
    puts "Compiling Static Files"
    SPROCKETS_ENV.each_logical_path do |lp|
      if asset = SPROCKETS_ENV.find_asset(lp)
        if asset.kind_of?(Sprockets::StaticAsset)
          target_filename =  SPROCKETS_DIGEST ? asset.digest_path : asset.logical_path
          pn = asset.pathname.to_s.gsub(SPROCKETS_SOURCE,'')
          prefix, basename = pn.to_s.split('/')[-2..-1]
          filename = File.join(SPROCKETS_OUTPUT, pn)
          FileUtils.mkpath(File.dirname(filename))
          asset.write_to(filename)
        end
      end
    end
  end
  
  # Cleanup asset directory
  task :cleanup do
    dirs = Dir.glob(File.join(File.join(SPROCKETS_OUTPUT,"{*.js,*.css}")))
    dirs.each do |dir|
      FileUtils.rm_rf dir
    end
  end

end



# Minify assets
module Minifier
  def Minifier.minify(files)
    files.each do |file|
      cmd = "java -jar ../tools/yuicompressor/build/yuicompressor-2.4.6.jar #{file[:src]} -o #{file[:dst]} --charset utf-8"
      puts cmd
      ret = system(cmd) # *** SYSTEM RUN LOCAL COMMANDS ***
      raise "Minification failed for #{file}" if !ret
    end
  end
end
