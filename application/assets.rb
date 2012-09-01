require 'uglifier'

# sprockets setup
set :sprockets,       Sprockets::Environment.new
Settings.sprockets['root']       = File.expand_path('../', __FILE__)
Settings.sprockets.paths['assets'] = Settings.sprockets.paths.static
Settings.sprockets.paths['assets'].push Settings.sprockets.paths.js
Settings.sprockets.paths['assets'].push Settings.sprockets.paths.css
Settings.sprockets.paths['assets'].push Settings.compass.images
Settings.sprockets.paths['assets'].push Settings.compass.fonts

# Sprockets.register_engine '.hbs', HandlebarsAssets::TiltHandlebars

searchpaths = []
%w{ application vendor lib}.each do |dir|
  Settings.sprockets["#{dir}_dir"] = File.join PROJECT_ROOT, dir, '/', Settings.sprockets.assets_prefix
  searchpaths.push Settings.sprockets["#{dir}_dir"]
end


configure do

  # settings.sprockets.css_compressor = Sprockets::Sass::Compressor.new
  settings.sprockets.js_compressor  = Uglifier.new(:mangle => true)

  # setup our paths
  searchpaths.each do |sp|
    Settings.sprockets.paths['assets'].each do |path|
      settings.sprockets.append_path File.join(sp, path)
    end
  end

  # configure Compass so it can find images
  Compass.add_project_configuration File.expand_path('compass.rb', File.dirname(__FILE__))
  # Compass.configuration do |compass|
  #   compass.project_path = Settings.sprockets['application_dir']
  #   compass.images_dir   = 'images'
  #   compass.output_style = :compressed
  # end

  # configure Sprockets::Helpers
  Sprockets::Helpers.configure do |config|
    config.environment = settings.sprockets
    config.prefix      = Settings.sprockets.assets_prefix
    config.digest      = Settings.sprockets.digest # digests are great for cache busting
    config.manifest    = Sprockets::Manifest.new(
      settings.sprockets,
      File.join(
        File.expand_path("../../public#{Settings.sprockets.assets_prefix}", __FILE__), 'manifest.json'
      )
    )

    # clean that thang out
    config.manifest.clean

    static_files     = []
    javascript_files = []

    searchpaths.each do |sp|
      # scoop up the images so they can come along for the party
      Settings.sprockets.paths.static.each do |asset_dir|
        Dir.glob(File.join(sp, asset_dir, '**', '*')).map do |filepath|
          static_files.push filepath.split('/').last
        end
      end

      # note: .coffee files need to be referenced as .js for some reason
      Dir.glob(File.join(sp, Settings.sprockets.paths.js, '**', '*')).map do |filepath|
        javascript_files.push filepath.split('/').last.gsub(/coffee/, 'js')
      end
    end

    # write the digested files out to public/assets (makes it so Nginx can serve them directly)
    config.manifest.compile(%w(style.css) | javascript_files | static_files)
  end
end
