require 'spec_helper'

describe Zf::Router do
  before do
    subject.describe do
      get '/users', ->(env) { [200, {}, ['users get handler']] }
      post '/users', ->(env) { [200, {}, ['users post handler']] }
      put '/user', ->(env) { [200, {}, ['user put handler']] }
      patch '/user', ->(env) { [200, {}, ['user patch handler']] }
      delete '/user', ->(env) { [200, {}, ['user delete handler']] }

      match :options, '/options', ->(env) { [200, {}, ['options handler']] }

      get '/posts/:id/show/:info', ->(env) { [200, {}, [env['router.params'].inspect]] }

      class TestController
        def self.action(action_name)
          ->(env) { [200, {}, ["test controller #{action_name} action"]] }
        end
      end

      get '/test', 'test#some'
    end
  end

  subject { Zf::Router.new }

  context 'when rack app passed' do
    describe 'HTTP methods matching' do
      [
        { env: { 'PATH_INFO' => '/users', 'REQUEST_METHOD' => 'GET' }, response: 'users get handler' },
        { env: { 'PATH_INFO' => '/users', 'REQUEST_METHOD' => 'POST' }, response: 'users post handler' },
        { env: { 'PATH_INFO' => '/user', 'REQUEST_METHOD' => 'PUT' }, response: 'user put handler' },
        { env: { 'PATH_INFO' => '/user', 'REQUEST_METHOD' => 'PATCH' }, response: 'user patch handler' },
        { env: { 'PATH_INFO' => '/user', 'REQUEST_METHOD' => 'DELETE' }, response: 'user delete handler' }
      ].each do |test_data|
        it "matches #{test_data[:env]['REQUEST_METHOD']}" do
          expect(subject.call(test_data[:env])).to eq [200, {}, [test_data[:response]]]
        end
      end

      it 'matches other HTTP methods' do
        expect(subject.call({ 'PATH_INFO' => '/options', 'REQUEST_METHOD' => 'OPTIONS' }))
          .to eq [200, {}, ['options handler']]
      end
    end

    describe 'params parsing' do
      it 'adds params to env' do
        expect(subject.call({ 'PATH_INFO' => '/posts/5/show/text', 'REQUEST_METHOD' => 'GET' }))
          .to eq [200, {}, ['{"id"=>"5", "info"=>"text"}']]
      end
    end
  end

  context 'when not found' do
    it 'returns not found response' do
      expect(subject.call({ 'PATH_INFO' => '/other', 'REQUEST_METHOD' => 'GET' }))
        .to eq [404, {}, ['Not found']]
    end
  end

  context 'when controller name passed' do
    it 'gets controller and calls action' do
      expect(subject.call({ 'PATH_INFO' => '/test', 'REQUEST_METHOD' => 'GET' }))
        .to eq [200, {}, ['test controller some action']]
    end
  end
end
