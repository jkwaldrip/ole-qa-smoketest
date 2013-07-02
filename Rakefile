require "bundler/gem_tasks"

desc "Remove old logfiles."
task :clean_logs do
  logdir = Dir["logs/*.log"].sort
  logdir.each {|file| logdir.delete(file) if file =~ /Smoketest\-2013\-07\-01\-1145/}
  logdir.each {|file| File.delete(file)}
end