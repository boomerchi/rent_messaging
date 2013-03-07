$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rent_messaging/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rent_messaging"
  s.version     = RentMessaging::VERSION
  s.authors     = ["Kristian Mandrup"]
  s.email       = ["kmandrup@gmail.com"]
  s.homepage    = "http://www.danrent.dk"
  s.summary     = "Messaging"
  s.description = "Handles messaging"

  # signing key and certificate chain
  s.signing_key = '/Users/kmandrup/gem-keys/gem-private_key.pem'
  s.cert_chain  = ['gem-public_cert.pem']  

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  # s.add_dependency "rails", ">= 4.0.0.beta1"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
