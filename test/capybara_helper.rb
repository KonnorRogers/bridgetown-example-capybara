# frozen_string_literal: true

require 'test_helper'
require 'rack'
require 'capybara'
require 'capybara/apparition'

# https://nts.strzibny.name/how-to-test-static-sites-with-rspec-capybara-and-webkit/
class BridgetownWebsite
  attr_reader :root, :server

  def initialize(root)
    @root = root
    @server = Rack::File.new(root)
  end

  def call(env)
    path = env['PATH_INFO']

    # Use index.html for / paths
    if path == '/' && exists?('index.html')
      env['PATH_INFO'] = '/index.html'
    elsif !exists?(path) && exists?(path + '.html')
      env['PATH_INFO'] += '.html'
    end

    server.call(env)
  end

  def exists?(path)
    File.exist?(File.join(root, path))
  end
end

# Setup for Capybara to test Bridgetown static files served by Rack
Capybara.app = Rack::Builder.new do
  map '/' do
    use Rack::Lint
    run BridgetownWebsite.new(File.join(File.expand_path(__dir__), 'output'))
  end
end.to_app

Capybara.register_driver :apparition do |app|
  Capybara::Apparition::Driver.new(app, {})
end

# port and url to webpack server
WEB_TEST_PORT = '4001'
WEB_TEST_URL = "http://localhost:#{WEB_TEST_PORT}"

Capybara.default_selector = :css
Capybara.javascript_driver = :apparition
Capybara.default_driver = :rack_test
Capybara.app_host = WEB_TEST_URL
Capybara.server = :webrick
Capybara.run_server = true

BUILD = Rake.sh('yarn webpack-build && bridgetown build')

# https://www.mikeperham.com/2018/10/12/testing-rubys-cgi/
WEBRICK = Thread.new do
  require 'webrick'

  server = WEBrick::HTTPServer.new(
    Port: WEB_TEST_PORT,
    DocumentRoot: File.join(File.expand_path('..', __dir__), 'output')
  )
  trap('INT') { server.shutdown }

  puts "Starting Webrick on port #{WEB_TEST_PORT}"
  server.start
end

require 'capybara/minitest'

class CapybaraTestCase < Minitest::Test
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end
