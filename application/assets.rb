# sprockets setup
set :sprockets,       Sprockets::Environment.new
Settings.sprockets['root']       = File.expand_path('../', __FILE__)
Settings.sprockets['assets_dir'] = File.join(Settings.sprockets['root'], Settings.sprockets.assets_prefix)

configure do
  # setup our paths
  Settings.sprockets.assets_paths.each do |path|
    settings.sprockets.append_path File.join(Settings.sprockets['assets_dir'], path)
  end

  # configure Compass so it can find images
  Compass.configuration do |compass|
    compass.project_path = Settings.sprockets['assets_dir']
    compass.images_dir   = 'images'
    compass.output_style = :compressed
  end

  # configure Sprockets::Helpers
  Sprockets::Helpers.configure do |config|
    config.environment = settings.sprockets
    config.prefix      = Settings.sprockets.assets_prefix
    config.digest      = true # digests are great for cache busting
    config.manifest    = Sprockets::Manifest.new(
      settings.sprockets,
      File.join(
        File.expand_path('../../public/assets', __FILE__), 'manifest.json'
      )
    )

    # clean that thang out
    config.manifest.clean

    # scoop up the images so they can come along for the party
    images = Dir.glob(File.join(Settings.sprockets['assets_dir'], 'images', '**', '*')).map do |filepath|
      filepath.split('/').last
    end

    # note: .coffee files need to be referenced as .js for some reason
    javascript_files = Dir.glob(File.join(Settings.sprockets['assets_dir'], 'javascripts', '**', '*')).map do |filepath|
      filepath.split('/').last.gsub(/coffee/, 'js')
    end

    # write the digested files out to public/assets (makes it so Nginx can serve them directly)
    config.manifest.compile(%w(style.css) | javascript_files | images)
  end
end
