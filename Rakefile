require_relative './app'
require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
require 'rake'
require 'rake/testtask'


Rake::TestTask.new do |t|
  t.pattern = "test/**/*_test.rb"
end

task default: :test
