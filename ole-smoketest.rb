#!/usr/bin/env ruby

#  Copyright 2005-2013 The Kuali Foundation
#
#  Licensed under the Educational Community License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at:
#
#    http://www.opensource.org/licenses/ecl2.php
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

dir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir)

require "lib/smoketest"

options = {}
# Parse options with OptionParser.
optparse = OptionParser.new do |opts|

  # Set banner message for OptionParser.
  opts.banner = "Kuali Open Library Environment - Smoketest Application\n (Default options are configured in \'lib/config/options.yml\'.)"

  opts.on('-h','--help',"Display this screen.") do
    puts opts
    exit
  end

  opts.on('-v','--version',"Print version number and exit.") do
    puts "Version #{OLE_QA::Smoketest::VERSION}"
    exit
  end

  opts.on('-l','--log [FILENAME]',"Log output to file, filename optional. \n        (Defaults to Smoketest-YYYY-MM-DD-HHMM.log)") do |logfile|
    options[:logging?] = true
    options[:logfile] = logfile || "Smoketest-#{OLE_QA::Smoketest::StartTime}.log"
    options[:logfile] += ".log" unless options[:logfile] =~ /\.log$/
  end

  opts.on('-n','--name NAME',"Set the name to use for the smoketest.\n        (Used mainly by SauceLabs sessions.)") do |name|
    options[:name] = name
  end

  opts.on('-t','--timestamp',"Prepend a timestamp to each output line.") do
    options[:timestamp?] = true
  end

  opts.on('-b','--browser WHICH',"Select the browser to use.") do |browser|
    options[:browser] = browser
  end

  opts.on('-x','--[no-]xvfb',"Use XVFB for headless testing.\n        (Unused if using SauceLabs.)") do |xvfb|
    options[:headless?] = xvfb
  end

  opts.on('-s','--sauce-labs',"Use SauceLabs connection.") do
    options[:capabilities?] = true
  end

  opts.on('-p','--platform OS',"Specify SauceLabs platform.") do |platform|
    options[:caps] = {} unless options.has_key?(:caps)
    options[:caps][:platform] = platform
  end

  opts.on('-B','--browser-version VERSION',"Specify SauceLabs browser version.") do |version|
    options[:caps] = {} unless options.has_key?(:caps)
    options[:caps][:version] = version
  end

  opts.on('-U','--sauce-username NAME',"Set SauceLabs username.") do |username|
    options[:sauce_username] = username
  end

  opts.on('-K','--sauce-api-key KEY',"Set SauceLabs API key.") do |sauce_key|
    options[:sauce_api_key] = sauce_key
  end

  opts.on('-w','--wait NN',"Set timeout option (in seconds).") do |wait_timeout|
    puts "Warning! Explicit Wait timeout is set to 0." unless wait_timeout.to_i > 0
    options[:explicit_wait] = wait_timeout.to_i
  end

  opts.on('-L','--ls',"List all files in scripts/ and exit.") do
    Dir["scripts/*.rb"].sort.each {|line| puts line.gsub("scripts/",'')}
    exit
  end

  opts.on('-T','--test-script "Test Name"',String,"Run a specific test script.") do |testscript|
    options[:testscript] = testscript
  end
end

optparse.parse!

OLE_QA::Smoketest.start(options)
OLE_QA::Smoketest.quit