require_relative 'lib/pgversion'

Gem::Specification.new do |gem|
  gem.authors       = ["Maciek Sakrejda"]
  gem.email         = ["m.sakrejda@gmail.com"]
  gem.description   = %q{Easy Postgres version utilities}
  gem.summary       = %q{Parse Postgres version strings and compare versions}
  gem.homepage      = "https://github.com/deafbybeheading/pgversion"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "pgversion"
  gem.require_paths = ["lib"]
  gem.version       = PGVersion::VERSION
  gem.license       = "MIT"

  gem.add_development_dependency "rspec", '~> 3.0'
end
