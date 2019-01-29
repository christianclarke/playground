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

  let(:gauge_dbl) do
    double
  end

  let(:counter_dbl) do
    double
  end

  before(:each) do
    allow(ENV).to receive(:[]).with('FIBONACCI_COUNT').and_return('20')
    allow(Prometheus::Client).to receive(:registry).and_return(prometheus_dbl)
    allow(prometheus_dbl).to receive(:register).and_return(nil)
    allow(gauge_dbl).to receive(:set).and_return(nil)
    allow(counter_dbl).to receive(:set).and_return(nil)
    allow_any_instance_of(Prometheus::Client::Gauge).to receive(:new).and_return(gauge_dbl)
    allow_any_instance_of(Prometheus::Client::Counter).to receive(:new).and_return(counter_dbl)
    allow(File).to receive(:read).and_return(":major: 1\n:minor: 0\n:patch: 0\n")
    allow(File).to receive(:exist?).and_return(true)
  end

  it 'displays a sequence of fibonacci integers' do
    get '/'
    expected_fibonacci_sequence = 'Here are 20 fibonacci integers 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181'
    expect(last_response.body).to eql(expected_fibonacci_sequence)
    expect(last_response.status).to eql(200)
  end

  describe 'the version endpoint' do
    it 'returns the app version' do
      get '/version'
      expect(last_response.status).to eql(200)
      expect(last_response.body).to eql('1.0.0')
    end
  end

  describe 'the healthz endpoint' do
    describe 'if the FIBONACCI_COUNT env var and the .semver file' do
      context 'is set/found' do
        it 'returns a HTTP 200' do
          get '/healthz'
          expect(last_response.status).to eql(200)
        end
      end

      context 'is not set/found' do
        before(:each) do
          allow(ENV).to receive(:[]).with('FIBONACCI_COUNT').and_return(nil)
          allow(File).to receive(:exist?).and_return(false)
        end

        it 'returns a HTTP 500' do
          get '/healthz'
          expect(last_response.status).to eql(500)
        end
      end
    end
  end
end
