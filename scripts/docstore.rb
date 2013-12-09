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

module OLE_QA::Smoketest::TestScripts
  # Create a bibliographic record and then verify that it appears in a DocStore search.
  class DocStore < OLE_QA::Smoketest::Script
    self.set_name('DocStore Test')
    include OLE_QA::Smoketest::MixIn::MarcEditor
    def run
      report('Create bib record.')
      bib_editor  = OLE_QA::Framework::OLELS::Bib_Editor.new(@ole)
      bib_info    = Array.new
      title       = OLE_QA::Framework::String_Factory.alphanumeric(12)
      report("#{'Title'.ljust(8)}: #{title}",1)
      author      = OLE_QA::Framework::String_Factory.alpha(8)
      report("#{'Author'.ljust(8)}: #{author}",1)
      bib_info << {:tag => '245', :value => title}
      bib_info << {:tag => '100', :value => author}
      bib_editor.open
      create_bib(bib_editor, bib_info)

      report('Open DocStore search screen.')
      ds_search   = OLE_QA::Framework::DocStore::Search.new(@ole)
      ds_search.open

      report('Search by title.')
      ds_search.search_field_1.set(title)
      ds_search.field_selector_1.select('Title')
      ds_search.search_button.click

      report('Check search results.')
      results     = OLE_QA::Framework::DocStore::Marc_Results.new(@ole)
      results.wait_for_page_to_load
      report("#{'Results present?'.ljust(25)}  #{results.any_results?}")
      verify { results.value_in_results(author).present? }
      report("#{'Target result found?'.ljust(25)}  #{results.value_in_results(author).present?}")

      report('Return to main menu.')
      @ole.open
    end
  end
end