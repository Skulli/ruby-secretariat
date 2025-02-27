require_relative "lib/secretariat/version"

Gem::Specification.new do |s|
  s.name = "secretariat"
  s.version = Secretariat::VERSION
  s.summary = "A ZUGFeRD xml generator"
  s.description = "a tool to help generate and validate ZUGFeRD invoice xml files"
  s.authors = ["Jan Krutisch"]
  s.email = "jan@krutisch.de"
  s.homepage = "https://github.com/halfbyte/ruby-secretariat"
  s.license = "Apache-2.0"

  s.extra_rdoc_files = ["README.md"]

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  s.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  s.bindir = "exe"
  s.executables = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 3.0.0"

  s.add_runtime_dependency "nokogiri", ">= 1.10"
  s.add_runtime_dependency "schematron-nokogiri", "~> 0.0", ">= 0.0.3"

  s.add_development_dependency "rake", ">= 13.0"

  s.add_development_dependency "rspec", "~> 3.0"
  s.add_development_dependency "standard"
  s.add_development_dependency "bigdecimal"
end
