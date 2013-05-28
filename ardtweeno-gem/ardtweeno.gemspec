require 'rubygems'
require 'rake'


Gem::Specification.new do |s|
  s.name        = 'ardtweeno'
  s.version     = '0.2.5'
  s.date        = '2013-05-19'
  s.summary     = 'Serial Device / IP Network Gateway designed as a PaaS to be run on the Raspberry Pi, exposes Sinatra API'
  s.description = <<-DESCRIPTION
Ardtweeno - Application Gateway bridges device connected through a serial link to devices connected 
over Internet Protocol. It is designed as a PaaS capable of being run on the ARM powered Raspberry Pi
Model B. It exposes a RESTAPI powered by Sinatra.
DESCRIPTION

  s.authors     = ['David Kirwan']
  s.email       = ['davidkirwanirl@gmail.com']
  s.require_paths = ["lib"]
  s.files       = FileList['lib/**/*.rb',
                      '[A-Z]*',
                      'bin/*',
                      'public/*',
                      'views/*',
                      'resources/*',
                      'test/**/*'].to_a
  s.homepage    = 'http://rubygems.org/gems/ardtweeno'
  s.executables = ['']
  s.required_ruby_version = '>= 1.8.7'
  s.post_install_message = <<-INSTALL
This software is released under the Attribution-NonCommercial 3.0 Unported (CC BY-NC 3.0) licence.
for more information see: http://creativecommons.org/licenses/by-nc/3.0/
INSTALL

  s.license   = 'CC BY-NC 3.0'
  s.add_dependency('bundler', '>= 1.2.3')
end