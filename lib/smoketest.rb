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
#  limitations under the License

require "headless"
require "watir-webdriver"
require "chronic"
require "optparse"
require "pp"
require "benchmark"
require "yaml"

require "ole-qa-tools"
require "ole-qa-framework"


module OLE_QA
  module Smoketest
    # Set date in format YYYY-MM-DD-HHMM
    StartTime = Time.new.strftime("%Y-%m-%d-%H%M")
    # Path to lib/
    LibDir = File.dirname(__FILE__)
    # Path to lib/..
    LoadDir = LibDir + "/../"

    Dir["#{LibDir}/smoketest/*.rb"].each {|file| require file}
    Dir["#{LibDir}/smoketest/*/*.rb"].each {|file| require file}

    # Create index of all test scripts.
    # e.g. {['Name of Test'] => TestClass}
    # @note Test scripts' names and classes are added when set_name is declared.
    @test_scripts = Hash.new

    class << self
      attr_accessor :test_scripts

      # Start an {OLE_QA::Smoketest::Session} and set up the necessary instance variables.
      def start(options = {})
        @options = options
        @session = OLE_QA::Smoketest::Session.new(@options)
        @ole     = @session.framework
        OLE_QA::Smoketest::Runner.run(@options[:testscript])
      end

      # Perform {OLE_QA::Smoketest::Session} teardowns and exit the program.
      def quit
        @session.quit
        exit
      end

      # View the options with which the Smoketest Session was started.
      attr_reader :options

      # Provide access to the Smoketest Session and its ole-qa-framework session.
      attr_accessor :session, :ole
    end

    # Declare TestScripts module for the first time to simplify naming in test scripts.
    module TestScripts
    end


    # Add custom error type.
    class Error < StandardError
    end
  end
end