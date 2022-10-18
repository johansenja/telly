require_relative "lib/telly/version"

Gem::Specification.new do |spec|
  spec.name        = "telly"
  spec.version     = Telly::VERSION
  spec.authors     = ["Joseph Johansen"]
  spec.email       = ["joe@stotles.com"]
  spec.homepage    = "https://github.com/johansenja/telly"
  spec.summary     = "Summary of Telly."
  spec.description = "Description of Telly."
    spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/johansenja/telly"
  spec.metadata["changelog_uri"] = "https://github.com/johansenja/telly"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 6.1"
  spec.add_dependency "rubocop", ">= 1.0"
end
