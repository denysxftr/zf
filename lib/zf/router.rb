class Zf::Router
  def describe(&block)
    instance_eval(&block)
  end

  def call(env)
    find_route(env).call(env)
  end

private

  def initialize
    @routes = {}
  end

  def find_route(env)
    method_routes = @routes[env['REQUEST_METHOD'].downcase.to_sym]
    method_routes && method_routes.each do |k, v|
      if env['PATH_INFO'] =~ k
        env['router.params'] = extract_params(v[:pattern], env['PATH_INFO'])
        return v[:app]
      end
    end
    return ->(env) { [404, {}, ['Not found']] }
  end

  def get(pattern, app); match(:get, pattern, app); end
  def post(pattern, app); match(:post, pattern, app); end
  def put(pattern, app); match(:put, pattern, app); end
  def patch(pattern, app); match(:patch, pattern, app); end
  def delete(pattern, app); match(:delete, pattern, app); end

  def match(http_method, path_pattern, app)
    http_method = http_method.to_sym
    @routes[http_method] ||= {}
    @routes[http_method][path_to_regexp(path_pattern)] = {
      pattern: path_pattern,
      app_str: app.to_s,
      app: get_controller(app)
    }
  end

  def extract_params(route, url)
    route
      .split('/')
      .zip(url.split('/'))
      .reject { |e| e.first == e.last }
      .map { |e| [e.first[1..-1], e.last] }
      .to_h
  end

  def path_to_regexp(path)
    Regexp.new('\A' + path.gsub(/:[a-zA-Z0-9_]+/, '[a-zA-Z0-9_]+') + '\Z')
  end

  def get_controller(app)
    return app unless app.is_a?(String)
    controller_name, action_name = app.split('#')
    Kernel.const_get(controller_name.capitalize + 'Controller').send(:action, action_name)
  end
end
