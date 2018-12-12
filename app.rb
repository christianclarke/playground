require 'sinatra'
require 'sinatra/base'
require 'prometheus'
require 'prometheus/client'

set :port, 8080
set :bind, '0.0.0.0'

# Sample Sinatra application
class App < Sinatra::Base
  prometheus = Prometheus::Client.registry
  # create a new counter metric
  http_requests = Prometheus::Client::Counter.new(:playground_request, 'A counter of HTTP requests made')
  # register the metric
  prometheus.register(http_requests)

  def shut_down
    puts 'Shutting down application.'
  end

  # Trap `Kill `
  Signal.trap('TERM') do
    shut_down
    exit 0
  end

  def compute_fibonnaci_integer(index)
    first = 0
    second = 1
    index.times do
      third = first + second
      first = second
      second = third
    end
    first
  end

  def fibonacci_sequence
    sequence = []
    20.times do |n|
      sequence << compute_fibonnaci_integer(n).to_s
    end
    sequence
  end

  get '/healthz' do
    status 200
    "Hello.  This is the healtcheck.  Hello and goodbye from sinatra! The time is #{Time.now}."
  end

  get '/' do
    status 200
    http_requests.increment({ fibonacci_sequence: 'hit_count', http_status: 200 }, 1)
    "Here are #{fibonacci_sequence.length} fibonacci integers #{fibonacci_sequence.join(', ')}"
  end

  get '/goodbye' do
    status 200
    "goodbye"
  end
end
