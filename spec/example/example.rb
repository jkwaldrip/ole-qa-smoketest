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

# Clear the Smoketest's test script index so that only the examples below are used.
OLE_QA::Smoketest.test_scripts.clear

module OLE_QA::Smoketest::TestScripts

  # Example test script that returns true on run.
  class PassExample < OLE_QA::Smoketest::Script
    self.set_name('Pass Example')
    def run
      true
    end
  end

  class FailExample < OLE_QA::Smoketest::Script
    self.set_name('Fail Example')
    def run
      assert { !true }
    end
  end

  class SessionExample < OLE_QA::Smoketest::Script
    self.set_name('Smoketest Session Example')
    def run
      raise StandardError, "Error" unless self.session.class == OLE_QA::Smoketest::Session
    end
  end

  class FrameworkExample < OLE_QA::Smoketest::Script
    self.set_name('Framework Session Example')
    def run
      raise StandardError, "Error" unless self.ole.class == OLE_QA::Framework::Session
    end
  end
end