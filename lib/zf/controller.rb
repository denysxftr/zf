require 'oj'

class Zf::Controller
  RESPONSE_TYPES = {
    text: ['text/plain', ->(c) { c }],
    json: ['application/json', ->(c) { c.is_a?(String) ? c : Oj.dump(c) }]
  }.freeze

  def self.action(action_name)
    proc { |env| new(action_name).call(env) }
  end

  def call(env)
    @request = Rack::Request.new(env)
    @request.params.merge!(env['router.params'] || {})
    send(@action)
    [@response_status, @response_headers, [@response_body]]
  end

private

  attr_reader :request

  def initialize(action_name)
    @action = action_name.to_sym
    @response_status = 200
    @response_body = ''
    @response_headers = {
      'Date' => Time.now.httpdate
    }
  end

  def response(param, content)
    @response_headers.merge!('Content-Type' => RESPONSE_TYPES[param.to_sym][0])
    @response_body = RESPONSE_TYPES[param.to_sym][1].call(content)
  end

  def params
    request.params
  end
end
