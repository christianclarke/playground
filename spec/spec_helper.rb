# spec/spec_helper.rb
require 'rack/test'
require 'rspec'
require File.expand_path '../app.rb', __dir__
Dir['./support/*.rb'].each do |f|
  require File.expand_path f, __dir__
end
