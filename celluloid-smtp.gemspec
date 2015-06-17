Gem::Specification.new do |gem|
  gem.name        = 'celluloid-smtp'
  gem.version     = '0.0.0.1'

  gem.summary     = "Celluloid based SMTP server."
  gem.description = "A small, fast, evented, actor-based, highly customizable Ruby SMTP server."

  gem.authors     = ["digitalextremist //"]
  gem.email       = 'code@extremist.digital'

  gem.files        = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|examples|spec|features)/}) }

  gem.homepage    = 'https://github.com/abstractive/celluloid-smtp'
  gem.license     = 'MIT'
end