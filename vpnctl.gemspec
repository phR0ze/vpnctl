Gem::Specification.new do |spec|
  spec.name        = 'vpnctl'
  spec.version     = '0.0.61'
  spec.summary     = "Simple GUI automation for openvpn"
  spec.authors     = ["Patrick Crummett"]
  spec.homepage    = 'https://github.com/phR0ze/vpnctl'
  spec.license     = 'MIT'
  spec.files       = ['vpnctl', 'vpnctl-ui']

  # Runtime dependencies
  spec.add_dependency('nub', '>= 0.0.136')

  # Development dependencies
  spec.add_development_dependency('minitest', '>= 5.11.3')
  spec.add_development_dependency('coveralls', '~> 0.8')
  spec.add_development_dependency('bundler', '~> 1.16')
  spec.add_development_dependency('rake', '~> 12.0')
end
# vim: ft=ruby:ts=2:sw=2:sts=2
