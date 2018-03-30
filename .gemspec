Gem::Specification.new do |spec|
  spec.name        = 'openvpn-gtk'
  spec.version     = '0.0.1'
  spec.summary     = "Simple GTK3 based GUI for openvpn Edit"
  spec.authors     = ["Patrick Crummett"]
  spec.homepage    = 'https://github.com/phR0ze/openvpn-gtk'
  spec.license     = 'MIT'
  spec.files       = ['openvpn-gtk', 'openvpn-cli']

  # Runtime dependencies
  spec.add_dependency('nub', '>= 0.0.32')
  spec.add_dependency('minitest', '>= 5.11.3')
  spec.add_dependency('rake', '~> 12.0')

  # Development dependencies
  spec.add_development_dependency('coveralls', '~> 0.8')
  spec.add_development_dependency('bundler', '~> 1.16')
  spec.add_development_dependency('rake', '~> 12.0')
end
# vim: ft=ruby:ts=2:sw=2:sts=2
