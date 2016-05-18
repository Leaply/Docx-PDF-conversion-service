#\ -s puma -p 8080
require File.expand_path('convert_service', File.dirname(__FILE__))
require 'raven'

Raven.configure do |config|
  config.dsn = 'https://fa74d34755274b4db0db48878b033f46:dd159c1f33d24b548cec22cc27a08400@app.getsentry.com/78821'
end

use Raven::Rack
run PdfApp
