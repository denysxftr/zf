require 'rack/lobster'
TestApplication = Zf::Application.new

class SampleMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    return [200, {}, ['middleware']] if env['PATH_INFO'] == '/middleware'
    @app.call(env)
  end
end

TestApplication.configure do
  views_dir File.dirname(File.expand_path(__FILE__)) + '/views'
  public_dir File.dirname(File.expand_path(__FILE__)) + '/public/'
  use SampleMiddleware
end

class TestController < Zf::Controller
  def show
    @message = params['message']
    response(:html, erb(:show))
  end
end

TestApplication.routes.describe do
  get '/show/:message', 'test#show'
end
