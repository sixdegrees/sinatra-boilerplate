guard 'livereload' do
  watch(%r{application/views/.+\.(erb|haml|slim)})
  watch(%r{application/helpers/.+\.rb})
  watch(%r{public/.+\.(css|js|html)})
  watch(%r{config/locales/.+\.yml})
  # Rails Assets Pipeline
  watch(%r{(application|vendor)/assets/\w+/(.+\.(scss|coffee|css|js|html)).*})  { |m| "/assets/#{m[2]}" }
end
