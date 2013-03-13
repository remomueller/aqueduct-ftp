# Compiling the Gem
# gem build aqueduct-ftp.gemspec
# gem install ./aqueduct-ftp-x.x.x.gem --no-ri --no-rdoc --local
#
# gem push aqueduct-ftp-x.x.x.gem
# gem list -r aqueduct-ftp
# gem install aqueduct-ftp

$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "aqueduct-ftp/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "aqueduct-ftp"
  s.version     = Aqueduct::Ftp::VERSION::STRING
  s.authors     = ["Remo Mueller"]
  s.email       = ["remosm@gmail.com"]
  s.homepage    = "https://github.com/remomueller"
  s.summary     = "Serve files using FTP through Aqueduct"
  s.description = "Connects to files through FTP using Aqueduct"
  s.license     = 'CC BY-NC-SA 3.0'

  s.files = Dir["{app,config,db,lib}/**/*"] + ["aqueduct-ftp.gemspec", "CHANGELOG.md", "LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails",     "~> 4.0.0.beta1"
  # s.add_dependency "aqueduct",  "~> 0.2.0" # Currently in Gemfile

  s.add_development_dependency "sqlite3"
end
