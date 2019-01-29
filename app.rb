require 'sinatra'
require 'sinatra/base'
require 'prometheus'
require 'prometheus/client'

set :port, 8080
set :bind, '0.0.0.0'

# Sample Sinatra application
class App < Sinatra::Base
  attr_accessor :fibonnaci_hit_count, :prometheus, :healthz_ok_count, :version

  def initialize(app = nil)
    @prometheus = Prometheus::Client.registry
    @fibonnaci_hit_count = Prometheus::Client::Counter.new(:playground_request, 'A counter of HTTP requests made')
    @healthz_ok_count = Prometheus::Client::Gauge.new(:healthz_not_ok_count, 'A gauge metric for bad health checks')

    @prometheus.register(@fibonnaci_hit_count)
    @prometheus.register(@healthz_ok_count)

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
      @healthz_ok_count.set({ healthcheck: 'nok' }, 0)
      'Hello.  Playground cannot run.  Check FIBONACCI_COUNT env var and semver file'
    else
      status 200
      @healthz_ok_count.set({ healthcheck: 'ok' }, 1)
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
