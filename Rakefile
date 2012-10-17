require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new do |task|
  task.libs << 'lib/bramipsum'
  task.test_files = FileList['test/**/test*.rb']
  task.verbose = true
end

desc "Run tests"
task :default => :test

