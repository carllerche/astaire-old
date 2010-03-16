Gem::Specification.new do |s|
  s.platform     = Gem::Platform::RUBY
  s.name         = 'astaire'
  s.version      = "0.0.1"
  s.summary      = 'The basic Sinatra DSL inside of ActionController'
  s.description  = 'Allows the use of get, post, put, and delete to define ' \
                   'actions and then allows the controller constant to be ' \
                   'used as a rack application.'

  s.author       = 'Carl Lerche'
  s.email        = 'clerche@engineyard.com'
  s.homepage     = 'http://github.com/carllerche/astaire'

  s.files        = Dir['README', 'LICENSE', 'lib/**/*']
  s.require_path = 'lib'

  s.add_dependency 'actionpack', '~> 3.0.0.beta1'
end