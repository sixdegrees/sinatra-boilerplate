# = bundle that shit
require 'rubygems' if RUBY_VERSION < '1.9'
require 'bundler' # gem requires
Bundler.require(:default)

PROJECT_ROOT = File.expand_path(File.dirname(__FILE__))
require './lib/settings'

# core Ruby requires, modules and the main app file
%w(securerandom timeout cgi date ./application/core).each do |requirement|
  require requirement
end

# = Middleware =
if Settings.dalli
  use Rack::Session::Dalli,             # session via memcached that sets a cookie reference
    :expire_after => 1800,              # 30 minutes
    :key          => 'rack_session',    # cookie name (probably change this)
    :secret       => 'change me', # Use `SecureRandom.hex(32)` to generate an unpredictable, 256bit randomly signed session cookies.
    :httponly     => true,              # bad js! No cookies for you!
    :compress     => true,
    :secure       => false,             # NOTE: if you're storing user authentication information in session set this to true and provide pages via SSL instead of standard HTTP or, to quote nkp, "risk the firesheep!"
    :path         => '/'
else
  use Rack::Session::Cookie
end
# rack middleware
use Rack::Deflect,            # prevents DOS attacks https://github.com/rack/rack-contrib/blob/master/lib/rack/contrib/deflect.rb
  :log => $stdout,            # should log appropriately
  :request_threshold => 100,  # number of requests
  :interval => 5,             # number of seconds to watch for :request_threshold
  :block_duration => 600      # number of seconds to block after :request_threshold has been hit
use Rack::CommonLogger
use Rack::Protection::SessionHijacking  # records a few pieces of browser info and stores in session
use Rack::Protection::IPSpoofing        # checks & protects against forwarded-for madness
use Rack::Protection::PathTraversal     # prevents path traversal

# = Configuration =
set :run,             false
set :server,          %w(unicorn)
set :show_exceptions, Settings.debug
set :raise_errors,    development?
set :views,           './application/views'
set :logging,         Settings.logging
set :static,          Settings.serve_static # your upstream server should deal with those (nginx, Apache)

#
# . . . . . . . . . . . . . . . . _,,,--~~~~~~~~--,_
# . . . . . . . . . . . . . . ,-' : : : :::: :::: :: : : : : :º '-, ITS A TRAP!
# . . . . . . . . . . . . .,-' :: : : :::: :::: :::: :::: : : :o : '-,
# . . . . . . . . . . . ,-' :: ::: :: : : :: :::: :::: :: : : : : :O '-,
# . . . . . . . . . .,-' : :: :: :: :: :: : : : : : , : : :º :::: :::: ::';
# . . . . . . . . .,-' / / : :: :: :: :: : : :::: :::-, ;; ;; ;; ;; ;; ;; ;\
# . . . . . . . . /,-',' :: : : : : : : : : :: :: :: : '-, ;; ;; ;; ;; ;; ;;|
# . . . . . . . /,',-' :: :: :: :: :: :: :: : ::_,-~~,_'-, ;; ;; ;; ;; |
# . . . . . _/ :,' :/ :: :: :: : : :: :: _,-'/ : ,-';'-'''''~-, ;; ;; ;;,'
# . . . ,-' / : : : : : : ,-''' : : :,--'' :|| /,-'-'--'''__,''' \ ;; ;,-'/
# . . . \ :/,, : : : _,-' --,,_ : : \ :\ ||/ /,-'-'x### ::\ \ ;;/
# . . . . \/ /---'''' : \ #\ : :\ : : \ :\ \| | : (O##º : :/ /-''
# . . . . /,'____ : :\ '-#\ : \, : :\ :\ \ \ : '-,___,-',-`-,,
# . . . . ' ) : : : :''''--,,--,,,,,,¯ \ \ :: ::--,,_''-,,'''¯ :'- :'-,
# . . . . .) : : : : : : ,, : ''''~~~~' \ :: :: :: :'''''¯ :: ,-' :,/\
# . . . . .\,/ /|\\| | :/ / : : : : : : : ,'-, :: :: :: :: ::,--'' :,-' \ \
# . . . . .\\'|\\ \|/ '/ / :: :_--,, : , | )'; :: :: :: :,-'' : ,-' : : :\ \,
# . . . ./¯ :| \ |\ : |/\ :: ::----, :\/ :|/ :: :: ,-'' : :,-' : : : : : : ''-,,
# . . ..| : : :/ ''-(, :: :: :: '''''~,,,,,'' :: ,-'' : :,-' : : : : : : : : :,-'''\\
# . ,-' : : : | : : '') : : :¯''''~-,: : ,--''' : :,-'' : : : : : : : : : ,-' :¯'''''-,_ .
# ./ : : : : :'-, :: | :: :: :: _,,-''''¯ : ,--'' : : : : : : : : : : : / : : : : : : :''-,
# / : : : : : -, :¯'''''''''''¯ : : _,,-~'' : : : : : : : : : : : : : :| : : : : : : : : :
# : : : : : : : :¯''~~~~~~''' : : : : : : : : : : : : : : : : : : | : : : : : : : : :
#

# = map it out for me
# sprockets
map Settings.sprockets.assets_prefix do
  run Sinatra::Application.sprockets
end

# main app
map '/' do
  run Sinatra::Application
end
