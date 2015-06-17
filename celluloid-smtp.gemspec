require File.expand_path("../culture/sync", __FILE__)

Gem::Specification.new do |gem|
  gem.name        = 'celluloid-smtp'
  gem.version     = Celluloid::SMTP::VERSION

  gem.summary     = "Celluloid based SMTP server."
  gem.description = "A small, fast, evented, actor-based, highly customizable Ruby SMTP server."

  gem.authors     = ["digitalextremist //"]
  gem.email       = 'code@extremist.digital'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.require_paths = ["lib"]

  gem.homepage    = 'https://github.com/abstractive/celluloid-smtp'
  gem.license     = 'MIT'

  gem.add_development_dependency "mail"
end
