loaddir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(loaddir) unless $LOAD_PATH.include?(loaddir)

require 'fileutils'

desc "Update Git repository."
task :update do
  msg_out = String.new
  orig_branch = `git rev-parse --abbrev-ref HEAD`.strip
  if orig_branch == 'master'
    msg_out = `git pull`.strip
  else
    msg_out = `git checkout master && git pull && git checkout #{orig_branch}`
  end
  puts "#{msg_out}"
end

desc "Remove old logfiles."
task :clean_logs do
  i = 0
  logdir = Dir["logs/*.log"].sort
  logdir.each {|file| logdir.delete(file) if file =~ /Smoketest\-2013\-07\-01\-1145/}
  logdir.each {|file| File.delete(file) ; i += 1}
  puts "#{i} logfiles removed."
end

desc "Remove old screenshots."
task :clean_screenshots do
  i = 0
  scrdir = Dir["screenshots/*.png"].sort
  scrdir.each {|file| scrdir.delete(file) if file =~ /2013-08-05-1300.png/}
  scrdir.each {|file| File.delete(file) ; i += 1}
  puts "#{i} screenshots removed."
end

desc "Select a config file from lib/config/addl."
task :select_config do
  puts 'Enter filename:'
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

desc "Search a logfile for errors specific to test scripts."
task :find_log_errors do
  puts 'Enter name of logfile:'
  target_file = STDIN.gets.chomp
  target_file += '.log' unless target_file =~ /\.log$/
  file_path = "#{loaddir}/logs/"
  if File.exists?(file_path + target_file)
    logfile = File.open(file_path + target_file)
    logfile.each do |line|
      if line =~ /#{loaddir}\/scripts\/.*\.rb/
        script_name = line.match(/(?<=scripts\/).*\.rb/)
        script_line_num = line.match(/(?<=\.rb\:)\d+/)
        puts "Logfile Line #{logfile.lineno} -- Error in #{script_name} at line #{script_line_num}"
      end
    end
  else
    puts "File not found: #{file_path}#{target_file}"
  end
end

desc "Search the most recent logfile for errors specific to test scripts."
task :find_latest_errors do
  target_file = Dir["#{loaddir}/logs/*.log"].sort[-1]
  puts "Logfile: #{target_file}"
  puts "(Custom filename found.  This may not be the latest logfile.)" unless target_file =~ /Smoketest-\d{4}-\d{2}-\d{2}-\d{4}\.log/
  logfile = File.open(target_file)
  logfile.each do |line|
    if line =~ /#{loaddir}\/scripts\/.*\.rb/
      script_name = line.match(/(?<=scripts\/).*\.rb/)
      script_line_num = line.match(/(?<=\.rb\:)\d+/)
      puts "Logfile Line #{logfile.lineno} -- Error in #{script_name} at line #{script_line_num}"
    end
  end
end