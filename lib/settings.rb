require 'settingslogic'

class Settings < Settingslogic
  env = ENV['ENVIRONMENT'] || "development"
  source "#{PROJECT_ROOT}/config/settings.yml"
  namespace env
  load!
end
