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
  # This mix-in module contains code to create Marc Bib, Instance, and Item Records.
  # - This module anticipates being included in the context of individual test scripts as-needed.
  # - Usage:
  #   class SomeTest < OLE_QA::Smoketest::Script
  #     self.set_name("Some Test")
  #     include OLE_QA::Smoketest::MarcEditor
  #     def run
  #       create_bib(opts)
  #       create_instance(opts)
  #       create_item(opts)
  #     end
  #   end
  #
  # - See individual methods for parameter requirements.
  #
  module MarcEditor

  end
end