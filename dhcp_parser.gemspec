# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dhcp_parser/version'

Gem::Specification.new do |spec|
  spec.name          = "dhcp_parser"
  spec.version       = DhcpParser::VERSION
  spec.authors       = ["Nguyen hoang anh"]
  spec.email         = ["anhnh@vccloud.vn"]

  spec.summary       = %q{Parser file dhcp.conf.}
  spec.description   = %q{Update convert file config to xml and write file xml}
  spec.homepage      = "https://github.com/hoanganhhanoi/dhcp_parser"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
end
