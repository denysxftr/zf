require 'spec_helper'

describe Zf::Controller do
  before { Timecop.freeze('2017-01-01T00:00:00+0000') }

  let(:controller) do
    Class.new(described_class) do
      def test_action
        response(:text, 'test')
      end

      def text_action
        response(:text, params.inspect)
      end

      def json_action
        response(:json, params)
      end
    end
  end

  describe '#action' do
    it 'returns proc' do
      expect(controller.action(:test)).to be_is_a(Proc)
    end

    it 'generated proc calls action' do
      expect(controller.action(:test_action).call(Rack::MockRequest.env_for('/')))
        .to eq([200, { 'Date' => 'Sun, 01 Jan 2017 00:00:00 GMT', 'Content-Type' => 'text/plain' }, ['test']])
    end
  end

  describe 'request processing' do
    subject do
      controller
        .action(action)
        .call(Rack::MockRequest.env_for('/?a=b').merge!(router_params))
    end

    let(:router_params) { {} }

    context 'when text response' do
      let(:action) { :text_action }

      it 'successfully responds' do
        expect(subject)
          .to eq([
            200,
            { 'Date' => 'Sun, 01 Jan 2017 00:00:00 GMT', 'Content-Type' => 'text/plain' },
            ['{"a"=>"b"}']
          ])
      end
    end

    context 'when json response' do
      let(:action) { :json_action }

      it 'successfully responds' do
        expect(subject)
          .to eq([
            200,
            { 'Date' => 'Sun, 01 Jan 2017 00:00:00 GMT', 'Content-Type' => 'application/json' },
            ['{"a":"b"}']
          ])
      end
    end

    context 'when has router params' do
      let(:router_params) { { 'router.params' => { 'param' => 'value' } } }
      let(:action) { :json_action }

      it 'successfully responds' do
        expect(subject)
          .to eq([
            200,
            { 'Date' => 'Sun, 01 Jan 2017 00:00:00 GMT', 'Content-Type' => 'application/json' },
            ['{"a":"b","param":"value"}']
          ])
      end
    end
  end
end
