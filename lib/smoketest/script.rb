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

module OLE_QA::Smoketest

  # Base class for an individual test script.
  # - When creating a test script, set module to OLE_QA::Smoketest::TestScripts.
  # - Declare set_name("Foo") just after class declaration, to be run on load.
  # - Put all test script evaluation instructions into the #run class method.
  #
  # e.g. --
  #
  # module OLE_QA::Smoketest::TestScripts
  #
  #   class ExampleTest
  #
  #     set_name("Example")
  #
  #     def self.run
  #       main_menu = OLE_QA::Framework::OLEFS::Main_Menu.new(ole)
  #       main_menu.open
  #       puts ole.browser.title.text
  #     end
  #   end
  # end
  #
  class Script

    include OLE_QA::Tools::Asserts

    # A hash containing the results of the test script's execution.
    attr_reader :results

    # Make the test script's name available after instantiation.
    attr_reader :test_name

    class << self
      # Add the name of the test to the test script index upon first load.
      def set_name(name_str)
        @test_name = name_str
        klas_name = self.name.split('::')[-1]
        OLE_QA::Smoketest.test_scripts[name_str] = klas_name
      end
      attr_reader :test_name
    end

    # The test script will run automatically when invoked with #new.
    def initialize
      # Retrieve test name from test script index.
      @test_name = OLE_QA::Smoketest.test_scripts.invert[self.class.name.split('::')[-1]]

      @results = Hash.new

      # Run the actual test steps.
      @results[:time] = Benchmark.realtime do
        begin
          self.run if defined?(self.run)
          @results[:outcome] = true
        rescue Watir::Wait::TimeoutError, Watir::Exception::UnknownObjectException, OLE_QA::Tools::Error, StandardError => e
          @results[:outcome] = false
        end
      end
      @results[:time] = self.format_time(@results[:time])

      # Report the results.
      @results[:outcome] ? outcome_str = 'Pass' : outcome_str = 'Fail'
      @results[:final] = @test_name.ljust(20) + '-- ' + outcome_str + " (#{@results[:time]})"
    end

    # Make a local alias for Smoketest Session.
    # @note Returns nil if Runner is not instantiated to $runner.
    def session
      OLE_QA::Smoketest.session
    end

    # Make a local alias for OLE Framework.
    # @note Returns nil if Runner is not instantiated to $runner.
    def ole
      OLE_QA::Smoketest.ole
    end

    # Local alias for {OLE_QA::Smoketest::Session#report}
    def report(str, hash_indent=0)
      session.report(str, hash_indent)
    end

    # Format the runtime for the current test.
    # @return [String] HH:MM:SS (seconds are rounded)
    def format_time(time_in_seconds)
      min, sec = time_in_seconds.divmod(60)
      hrs, min = min.divmod(60)
      "#{format("%02d",hrs)}:#{format("%02d",min)}:#{format("%02d",sec.round)}"
    end
  end
end