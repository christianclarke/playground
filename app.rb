require 'sinatra'
require 'sinatra/base'
require 'prometheus'
require 'prometheus/client'

set :port, 8080
set :bind, '0.0.0.0'

# Sample Sinatra application
class App < Sinatra::Base
  attr_accessor :fibonnaci_hit_count, :prometheus, :healthz_state, :version

  def initialize(app = nil)
    @prometheus = Prometheus::Client.registry
    @fibonnaci_hit_count = Prometheus::Client::Counter.new(:playground_request, 'A counter of HTTP requests made')
    @healthz_state = Prometheus::Client::Gauge.new(:healthz_state, 'A gauge metric for health checks')

    @prometheus.register(@fibonnaci_hit_count)
    @prometheus.register(@healthz_state)

    if File.exist?('.semver')
      semver_file = File.read('.semver').split
      @version = semver_file.values_at(* semver_file.each_index.select {|i| i.odd?}).join('.')
    end

    super(app)
  end

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
    ENV['FIBONACCI_COUNT'].to_i.times do |n|
      sequence << compute_fibonnaci_integer(n).to_s
    end
    sequence
  end

  get '/version' do
    @version
  end

  get '/healthz' do
    if ENV['FIBONACCI_COUNT'].nil? && !File.exist?('.semver')
      status 500
      @healthz_state.set({ healthcheck: 'FAIL' }, 0)
      'Hello.  Playground cannot run.  Check FIBONACCI_COUNT env var and semver file'
    else
      status 200
      if @healthz_state.get({ healthcheck: 'PASS' }) == 300
        @healthz_state.set({ healthcheck: 'PASS' }, 100)
      else
        @healthz_state.set({ healthcheck: 'PASS' }, 300)
      end

      'Hello.  Playground is up and running.'
    end
  end

  get '/' do
    if ENV['FIBONACCI_COUNT'].nil?
      status 500
    else
      status 200
      @fibonnaci_hit_count.increment
      "Here are #{fibonacci_sequence.length} fibonacci integers #{fibonacci_sequence.join(', ')}"
    end
  end
end
