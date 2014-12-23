# encoding: UTF-8

require 'rake'
require 'rspec/core/rake_task'
require 'active_support'
require 'active_support/core_ext'
require 'active_record'
require 'logger'
require 'yaml'

desc "Migrate the database through scripts in db/migrate/."
task :migrate => :environment do
    ActiveRecord::Migrator.migrate('db/migrate/', ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
end

desc "Create an empty migration in db/migrate/ e.g., rake generate:migration NAME=create_tasks"
task :migration do
  unless ENV.has_key?('NAME')
    raise "Must specificy migration name, e.g., rake generate:migration NAME=create_tasks"
  end

  name     = ENV['NAME'].camelize
  filename = "%s_%s.rb" % [Time.now.strftime('%Y%m%d%H%M%S'), ENV['NAME'].underscore]
  path     = File.join('db/migrate', filename)

  if File.exist?(path)
    raise "ERROR: File '#{path}' already exists"
  end

  puts "Creating #{path}"
  File.open(path, 'w+') do |f|
    f.write(<<-EOF.strip_heredoc)
      class #{name} < ActiveRecord::Migration
        def change
        end
      end
    EOF
  end
end

desc "Rollback the database"
task :rollback => :environment do
    ActiveRecord::Migrator.rollback('db/', ENV["STEP"] ? ENV["STEP"].to_i : 1 )
end

desc "Insert default data into database"
task :seed do
  dbconfig = YAML.load(File.open("config/database.yml").read)
  dbconfig.each do |key,config|
    puts "Load database : #{config['database'].to_s}"
    ActiveRecord::Base.establish_connection(config)
    load "db/seeds.rb"
  end
end

task :environment do
    dbconfig = YAML.load(File.open("config/database.yml").read)
    env = ENV["RACK_ENV"] || "test"
    ActiveRecord::Base.establish_connection(dbconfig[env])
    ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'a'))
end

if ENV["RACK_ENV"] == 'test'
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new :specs do |task|
    task.pattern = Dir['spec/**/*_spec.rb']
    task.rspec_opts = ['-fd']
    task.verbose = false
  end

  task :default => ['specs']
end

task :default => ['migrate']
