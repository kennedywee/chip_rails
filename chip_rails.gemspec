# frozen_string_literal: true

require_relative "lib/chip_rails/version"

Gem::Specification.new do |spec|
  spec.name = "chip_rails"
  spec.version = ChipRails::VERSION
  spec.authors = ["Kennedy Wee"]
  spec.email = ["kennedyweesupitang@gmail.com"]

  spec.summary = "Integrate Chip-in-Asia payment gateway with Ruby on Rails applications."
  spec.homepage = "https://github.com/kennedywee/chip_rails"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/kennedywee/chip_rails"
  spec.metadata["changelog_uri"] = "https://github.com/kennedywee/chip_rails/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'net-http', '~> 0.4'
  spec.add_dependency 'uri', '~> 0.13'
  spec.add_dependency 'json', '~> 2.7'
  spec.add_dependency 'ostruct', '~> 0.6'
  spec.add_dependency 'openssl', '~> 3.2'
  spec.add_dependency 'dotenv', '~> 2.8'
end
