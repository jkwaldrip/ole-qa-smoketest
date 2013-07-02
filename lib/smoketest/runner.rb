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

module OLE_QA::Smoketest
  # Class to perform actual test execution.
  # - Test scripts will evaluate in the context of this class.
  class Runner
    # Include assertions module from ole-qa-tools.
    include OLE_QA::Tools::Asserts

    # Initialize and run all given tests.
    def initialize(options = {})
      # Make options accessible across instance.
      @options = options

      # Set instance variables to be used during test script evaluation.
      @number = String.new
      @name = String.new
      @time = 0.0
      @outcome = false

      # Start OLE QA Smoketest Session.
      # @note Pass $ole to OLE QA Framework pages and data objects in test scripts.
      @session = OLE_QA::Smoketest::Session.new(@options)
      @ole = @session.framework

      # Evaluate test scripts.
      if @options.include?(:testscript)
        @number = "1."
        run_test(@options[:testscript])
      else
        @testscripts = Dir["#{OLE_QA::Smoketest::LoadDir}/scripts/*.rb"].sort
        @testscripts.each do |script|
          @number = "#{(@testscripts.index(script) + 1)}."
          run_test(script)
        end
      end

      # Quit OLE_QA::Smoketest::Session
      @session.quit
    end

    # Execute a single target test or all tests in the "scripts/" directory.
    def run_test(test_file)
      @time = Benchmark.realtime { eval(File.read("#{test_file}")) }
      @outcome = true
    rescue Watir::Wait::TimeoutError, Watir::Exception::UnknownObjectException, OLE_QA::Tools::Error => e
      @outcome = false
      report(e.message)
    ensure
      results = "#{@number}  #{@name.ljust(20)} -- #{(@outcome ? "Pass" : "Fail")} (#{format_time(@time)})"
      puts(results) if @session.opts[:logging?]
      report(results)
    end

    # Format the runtime for the current test.
    # @return [String] HH:MM:SS (seconds are rounded)
    def format_time(time_in_seconds)
      min, sec = time_in_seconds.divmod(60)
      hrs, min = min.divmod(60)
      "#{format("%02d",hrs)}:#{format("%02d",min)}:#{format("%02d",sec.round)}"
    end

    # Set the name of the currently-running test script and add it to the logfile.
    def set_name(str)
      @name = str
      expected_length = 20
      raise OLE_QA::Smoketest::Error, "Test name must be less than #{expected_length} characters." if @name.length > expected_length
      @session.report(str) if @session.opts[:logging?]
    end

    # Local alias for {OLE_QA::Smoketest::Session#report}
    def report(str, hash_indent=0)
      @session.report(str, hash_indent)
    end
  end
end