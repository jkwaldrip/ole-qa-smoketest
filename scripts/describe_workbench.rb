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
  # Test the search, view, and edit functions of the Describe Workbench.
  class DescribeWorkbench < OLE_QA::Smoketest::Script
    self.set_name("Describe Test")
    include OLE_QA::Smoketest::MixIn::MarcEditor
    def run
      report('Create target bib record.')
      bib_editor = OLE_QA::Framework::OLELS::Bib_Editor.new(@ole)
      bib_editor.open
      
      # Create a string of 10 random alphanumerics to use as a search target.
      rand_str = OLE_QA::Framework::String_Factory.alphanumeric(9)
      title  = 'Describe Workbench Test ' + rand_str
      author = 'OLE QA Smoketest '        + rand_str
      report("Random search target string:  #{rand_str}",1)

      # Create bib record.
      bib_info = Array.new
      bib_info << {:tag => '245', :value => '|a' + title}
      bib_info << {:tag => '100', :value => '|a' + author}
      create_bib(bib_editor, bib_info)
      
      report('Create target instance record.')
      instance_editor = OLE_QA::Framework::OLELS::Instance_Editor.new(@ole)
      instance_info = {:location => 'B-EDUC/BED-STACKS',
        :call_number => OLE_QA::Framework::Bib_Factory.call_number,
        :call_number_type => 'LCC'}
      create_instance(instance_editor, instance_info)

      report('Create target item record.')
      item_editor = OLE_QA::Framework::OLELS::Item_Editor.new(@ole)
      item_info = {:item_type => 'Book',
        :item_status => 'Available',
        :barcode => OLE_QA::Framework::Bib_Factory.barcode}
      create_item(item_editor, item_info)

      report('Open describe workbench.')
      workbench = OLE_QA::Framework::OLELS::Describe_Workbench.new(@ole)
      workbench.open


      report('Search for bib record by title.')
      workbench.wait_for_page_to_load
      workbench.doc_type_bib.when_present.set
      workbench.search_field_1.when_present.set(rand_str)
      workbench.search_field_selector_1.when_present.select('Title')
      workbench.search_button.when_present.click
      assert(120)   { workbench.result_present?(rand_str) }
      report('Results confirmed.',1)

      report('Search for holdings record by call number.')
      workbench.clear_button.when_present.click
      workbench.wait_for_page_to_load
      workbench.doc_type_holdings.when_present.set
      Watir::Wait.until { workbench.search_field_selector_1.present? && workbench.search_field_selector_1.include?('Call Number') }
      workbench.search_field_1.set(instance_info[:call_number])
      workbench.search_field_selector_1.select('Call Number')
      workbench.search_button.when_present.click
      assert(120)   { workbench.result_present?(rand_str)}
      assert(120)   { workbench.result_present?(instance_info[:call_number])}
      report('Results confirmed.',1)

      report('Search for item record by barcode.')
      workbench.clear_button.when_present.click
      workbench.wait_for_page_to_load
      workbench.doc_type_item.when_present.set
      Watir::Wait.until { workbench.search_field_selector_1.present? && workbench.search_field_selector_1.include?('Item Barcode') }
      workbench.search_field_1.set(item_info[:barcode])
      workbench.search_field_selector_1.select('Item Barcode')
      workbench.search_button.when_present.click
      assert(120)   { workbench.result_present?(rand_str)}
      assert(120)   { workbench.result_present?(item_info[:barcode])}
      report('Results confirmed.',1)
    end
  end
end
