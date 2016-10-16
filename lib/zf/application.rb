class Zf::Application
  extend Forwardable

  attr_reader :routes

  def call(env)
    env['zf'] = {}
    env['zf']['views_dir'] = @views_dir
    @rack_builder.call(env)
  end

  def configure(&block)
    instance_eval(&block)
    @rack_builder.use(Rack::Static, root: File.dirname(@public_dir), urls: ['/' + File.basename(@public_dir)])
    @rack_builder.run(@routes)
  end

private

  def initialize
    @routes = Zf::Router.new

    @public_dir = File.join(File.expand_path('.'), 'public')
    @views_dir = File.join(File.expand_path('.'), 'views')

    @rack_builder = Rack::Builder.new
  end

  def_delegator :@rack_builder, :use

  def views_dir(new_path)
    @views_dir = new_path
  end

  def public_dir(new_path)
    @public_dir = new_path
  end
end
