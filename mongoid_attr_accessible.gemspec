# -*- mode: ruby -*-

Gem::Specification.new do |s|
  s.name = "mongoid_attr_accessible"
  s.version = "0.0.1"
  s.author = "Eric Kidd"
  s.email = "git@randomhacks.net"
  s.homepage = "http://github.com/emk/mongoid_attr_accessible"
  s.platform = Gem::Platform::RUBY
  s.summary = "attr_accessible for Mongoid"
  s.require_path = "lib"

  s.add_dependency('mongoid', '>= 1.9', '< 2.0')
  s.add_dependency('mongo', '>= 1.0.1')
  s.add_dependency('bson_ext', '>= 1.0.1')

  s.add_development_dependency('rake', '>= 0.8.3')
  s.add_development_dependency('rspec', '>= 1.3.0')
  s.add_development_dependency('mocha', '>= 0.9.8')
end
