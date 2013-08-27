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

module OLE_QA
  module Smoketest
    # Class to perform actual test execution.
    class Runner
      # Run all available test scripts or given testscript.
      # @param testscript [String] The name of a testscript.
      # @raise OLE_QA::Smoketest::Error if the testscript is not found in {OLE_QA::Smoketest.test_scripts}
      def self.run(testscript = nil)
        if testscript
          raise OLE_QA::Smoketest::Error,"Test not found.\n(Given: #{testscript})" \
            unless OLE_QA::Smoketest.test_scripts.include?(testscript)
          self.run_one(testscript)
        else
          OLE_QA::Smoketest.test_scripts.keys.sort.each {|script_name| self.run_one(script_name)}
        end
      end

      def self.run_one(script_name)
        klas_name = OLE_QA::Smoketest.test_scripts[script_name]
        klas = OLE_QA::Smoketest::TestScripts.const_get(klas_name)
        klas.new
      end
    end
  end
end
