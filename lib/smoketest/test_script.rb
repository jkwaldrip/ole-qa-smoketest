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
  class TestScript
    # .new invokes .run
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
  end
end