require "bundler/setup"
require "rake/testtask"

# Immediately sync all stdout so that tools like buildbot can
# immediately load in the output.
$stdout.sync = true
$stderr.sync = true

# Change to the directory of this file.
Dir.chdir(File.expand_path("../", __FILE__))

Bundler::GemHelper.install_tasks

Rake::TestTask.new do |task|
  task.test_files = FileList['test/**/test*.rb']
end

desc "Run tests"
task :default => :test

