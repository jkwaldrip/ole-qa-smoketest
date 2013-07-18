loaddir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(loaddir) unless $LOAD_PATH.include?(loaddir)

require 'fileutils'

desc "Remove old logfiles."
task :clean_logs do
  i = 0
  logdir = Dir["logs/*.log"].sort
  logdir.each {|file| logdir.delete(file) if file =~ /Smoketest\-2013\-07\-01\-1145/}
  logdir.each {|file| File.delete(file) ; i += 1}
  puts "#{i} logfiles removed."
end

desc "Select a config file from lib/config/addl."
task :select_config do
  puts 'Enter filename:  '
  target_file = STDIN.gets.chomp
  target_file += '.yml' unless target_file =~ /\.yml$/
  file_path = "#{loaddir}/lib/config/"
  if File.exists?(file_path + 'addl/' + target_file)
    FileUtils.cp "#{file_path}addl/#{target_file}", "#{file_path}options.yml"
    puts "Successfully copied #{file_path}addl/#{target_file}."
  else
    puts "File not found: #{file_path}addl/#{target_file}"
  end
end
