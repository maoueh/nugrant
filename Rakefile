require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new do |task|
  task.test_files = FileList['test/**/test*.rb']
end

desc "Run tests"
task :default => :test

