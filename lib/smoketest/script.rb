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
  # Include Test Script Classes in this namespace.
  module TestScripts

    @test_index = Hash.new

    def self.index
      @test_index
    end

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

      # The test script will run automatically when invoked with #new.
      def initialize
        self.run if defined?(self.run)
      end

      # Make a local alias for Smoketest Session.
      def session
        OLE_QA::Smoketest::Runner.session
      end

      # Make a local alias for OLE Framework.
      def ole
        OLE_QA::Smoketest::Runner.ole
      end

      # Add the name of the test to the test script index.
      def self.set_name(name_str)
        @test_name = name_str
        klas_name = self.class
        OLE_QA::Smoketest::TestScripts.index[name_str] = klas_name
      end

      # Reader class method for test script name.
      def self.test_name
        return @test_name
      end
    end
  end
end