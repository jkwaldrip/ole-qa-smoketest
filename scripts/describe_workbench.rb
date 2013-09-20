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
      report("Create target bib record.")
      bib_editor = OLE_QA::Framework::OLELS::Bib_Editor.new(@ole)
      bib_editor.open
      
      # Create a string of 10 random alphanumerics to use as a search target.
      rand_str = rand(36**10).to_s(36).upcase
      title  = 'Describe Workbench Test ' + rand_str
      author = 'OLE QA Smoketest '        + rand_str
      report("Random search target string:  #{rand_str}",1)
      
      bib_info = Array.new
      bib_info << {:tag => '008', :value => 'DescribeWorkbenchTest'}
      bib_info << {:tag => '245', :value => '|a' + title}
      bib_info << {:tag => '100', :value => '|a' + author}

      create_bib(bib_editor, bib_info)
      
      report('Create target instance record.')
      instance_editor = OLE_QA::Framework::OLELS::Instance_Editor.new(@ole)
      bib_editor.holdings_link(1).when_present.click
      instance_editor.wait_for_page_to_load
      instance_editor.location_field.set('B-EDUC/BED-STACKS')
      call_number = OLE_QA::Tools::Data_Factory::Bib_Factory.call_number
      instance_editor.call_number_field.set(call_number)
      report("Call number: #{call_number}",1)
      instance_editor.call_number_type_selector.select_value('LCC')
      instance_msg = instance_editor.save_record
      report(instance_msg,1)

      report('Create target item record.')
      item_editor = OLE_QA::Framework::OLELS::Item_Editor.new(@ole)
      unless instance_editor.item_link.present?
        instance_editor.holdings_icon.click
        instance_editor.item_link.wait_until_present
      end
      instance_editor.item_link.when_present.click
      item_editor.wait_for_page_to_load
      barcode = OLE_QA::Tools::Data_Factory::Bib_Factory.barcode
      item_editor.barcode_field.set(barcode)
      report("Barcode:  #{barcode}",1)
      item_editor.item_status_selector.select('Available')
      item_editor.item_type_selector.select('book')
      item_msg = item_editor.save_record
      report(item_msg,1)

      report('Open describe workbench.')
      workbench = OLE_QA::Framework::OLELS::Describe_Workbench.new(@ole)
      workbench.open

      report('Search for bib record by title.')
      workbench.doc_type_bib.set
      workbench.search_field_1.when_present.set(rand_str)
      workbench.search_field_selector_1.when_present.select('Title')
      workbench.search_button.when_present.click

      

    end
  end
end
