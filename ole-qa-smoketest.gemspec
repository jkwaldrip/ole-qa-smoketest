# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'smoketest/VERSION'

Gem::Specification.new do |spec|
  spec.name          = "ole-qa-smoketest"
  spec.version       = OLE_QA::Smoketest::VERSION
  spec.authors       = ["Jain Waldrip"]
  spec.email         = ["jkwaldri@indiana.edu"]
  spec.description   = "Kuali Open Library Environment Smoketest Application"
  spec.summary       = "Kuali Open Library Environment"
  spec.homepage      = "http://github.com/jkwaldrip/ole-qa-smoketest"
  spec.license       = "ECLv2"

  spec.files         = Dir.glob("**/**/**")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib","scripts","logs"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "yard"

  spec.add_dependency "ole-qa-framework"
  spec.add_dependency "ole-qa-tools",">= 0.3.0"
  spec.add_dependency "chronic"
  spec.add_dependency "watir-webdriver"
  spec.add_dependency "headless"
end
