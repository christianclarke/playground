# spec/app_spec.rb
require File.expand_path 'spec_helper.rb', __dir__

describe 'Sinatra App' do
  include Rack::Test::Methods

  def app
    App.new
  end

  it 'displays a sequence of fibonacci integers' do
    get '/'
    expected_fibonacci_sequence = 'Here are 20 fibonacci integers 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181'
    expect(last_response.body).to eql(expected_fibonacci_sequence)
    expect(last_response.status).to eql(401)
  end

  it 'the healthz endpoint returns a 200' do
    get '/healthz'
    expect(last_response.status).to eql(200)
  end
end
