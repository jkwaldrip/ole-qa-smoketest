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

# Override Watir-Webdriver's Default Wait Behaviors with Aliases
# - Allows non-explicit use of OLE QA Framework's explicit wait option.
#   (e.g. --
#       requisition.building_search_icon.wait_until_present
#   evaluates as --
#       requisition.building_search_icon.wait_until_present(@framework.explicit_wait)
#    )



module Watir
  # Use OLE QA Smoketest wait as the default timeout for wait methods used by the Browser class & Waitable module.
  module Wait
    class << self
      # until
      alias_method(:old_until, :until)
      def until(timeout = OLE_QA::Smoketest.wait, message = nil, &block)
        self.old_until(timeout, message, &block)
      end

      # while
      alias_method(:old_while, :while)
      def while(timeout = OLE_QA::Smoketest.wait, message = nil, &block)
        self.old_while(timeout, message, &block)
      end
    end
  end

  # Use OLE QA Smoketest wait as the default timeout for wait methods inherited by Element class.
  module EventuallyPresent
    # Element.wait_until_present
    alias_method(:old_wait_until_present, :wait_until_present)
    def wait_until_present(timeout = OLE_QA::Smoketest.wait)
      self.old_wait_until_present(timeout)
    end

    # Element.wait_while_present
    alias_method(:old_wait_while_present, :wait_while_present)
    def wait_while_present(timeout = OLE_QA::Smoketest.wait)
      self.old_wait_while_present(timeout)
    end

    # Element.when_present
    alias_method(:old_when_present, :when_present)
    def when_present(timeout = OLE_QA::Smoketest.wait)
      self.old_when_present(timeout)
    end
  end
end