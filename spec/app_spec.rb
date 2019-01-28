# spec/app_spec.rb
require File.expand_path 'spec_helper.rb', __dir__

describe 'Sinatra App' do
  include Rack::Test::Methods

  def app
    App.new
  end

  let(:prometheus_dbl) do
    double
  end

  before(:each) do
    allow(ENV).to receive(:[]).with('FIBONACCI_COUNT').and_return('20')
    allow(Prometheus::Client).to receive(:registry).and_return(prometheus_dbl)
    allow(prometheus_dbl).to receive(:register).and_return(nil)
  end

  it 'displays a sequence of fibonacci integers' do
    get '/'
    expected_fibonacci_sequence = 'Here are 20 fibonacci integers 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181'
    expect(last_response.body).to eql(expected_fibonacci_sequence)
    expect(last_response.status).to eql(200)
  end

  describe 'the healthz endpoint' do
    describe 'if the the FIBONACCI_COUNT env var' do
      context 'is set' do
        it 'returns a HTTP 200' do
          get '/healthz'
          expect(last_response.status).to eql(200)
        end
      end

      context 'is not set' do
        it 'returns a HTTP 500' do
          allow(ENV).to receive(:[]).with('FIBONACCI_COUNT').and_return(nil)
          get '/healthz'
          expect(last_response.status).to eql(500)
        end
      end
    end
  end
end
