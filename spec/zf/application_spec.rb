require 'spec_helper'
require_relative './../fixtures/test_app'

describe Zf::Application do
  before { Timecop.freeze('2017-01-01T00:00:00+0000') }
  subject { TestApplication }

  describe '.configure' do
    it 'configures static files serving' do
      response = TestApplication.call(Rack::MockRequest.env_for('/public/test.txt'))
      response[2].each do |file_content|
        expect(file_content).to eq "test file\n"
      end
    end

    it 'configures middlewares' do
      response = TestApplication.call(Rack::MockRequest.env_for('/middleware'))
      expect(response).to eq [200, {}, ['middleware']]
    end

    it 'configures views path' do
      response = TestApplication.call(Rack::MockRequest.env_for('/show/info'))
      expect(response)
        .to eq([
          200,
          { 'Date' => 'Sun, 01 Jan 2017 00:00:00 GMT', 'Content-Type' => 'text/html' },
          ["<h1>info</h1>\n"]
        ])
    end
  end
end
