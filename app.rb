require 'sinatra'
require 'sinatra/base'

set :port, 8080
set :bind, '0.0.0.0'

class App < Sinatra::Base

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

  get '/version' do
    status 200
    '0.8.0'
  end

  get '/healthz' do
    status 200
    "Hello.  This is the healtcheck code.  Hello and goodbye from sinatra! The time is #{Time.now}."
  end

  get '/' do
    "Here are 10 fibonacci integers #{fibonacci_sequence.join(', ')}"
  end
end
