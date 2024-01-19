require_relative './app'
require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
require 'rake'
require 'rake/testtask'


task :test do

  APP_ENV = 'test' # Force the environment to test

  puts  "** Recreating the test database **"
  Rake::Task['db:test:prepare'].invoke

  puts "** Seeding the database with fixtures **"
  Rake::Task['db:fixtures:load'].invoke

  puts "** Executing Tests **"
  Rake::TestTask.new do |t|
    t.pattern = "test/**/*_test.rb"
  end
end

task default: :test
