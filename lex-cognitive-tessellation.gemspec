# frozen_string_literal: true

require_relative 'lib/legion/extensions/cognitive_tessellation/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-cognitive-tessellation'
  spec.version       = Legion::Extensions::CognitiveTessellation::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']
  spec.summary       = 'Cognitive pattern tiling and coverage analysis for LegionIO agents'
  spec.description   = 'Models how cognitive patterns tile together to cover conceptual space ' \
                       'detecting gaps, overlaps, and coherence in knowledge mosaics'
  spec.homepage      = 'https://github.com/LegionIO/lex-cognitive-tessellation'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata = {
    'homepage_uri'          => spec.homepage,
    'source_code_uri'       => spec.homepage,
    'documentation_uri'     => "#{spec.homepage}/blob/master/README.md",
    'changelog_uri'         => "#{spec.homepage}/blob/master/CHANGELOG.md",
    'bug_tracker_uri'       => "#{spec.homepage}/issues",
    'rubygems_mfa_required' => 'true'
  }

  spec.files = Dir.chdir(__dir__) { `git ls-files -z`.split("\x0") }
  spec.require_paths = ['lib']
  spec.add_development_dependency 'legion-gaia'
end
