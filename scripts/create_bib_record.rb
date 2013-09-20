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
  # Create a MARC bibliographic record with holdings and item in the editor.
  class BibEditor < OLE_QA::Smoketest::Script
    self.set_name("Bib Editor Test")
    include OLE_QA::Smoketest::MixIn::MarcEditor
    def run

      report('Open Bib Editor.')
      bib_editor = OLE_QA::Framework::OLELS::Bib_Editor.new(@ole)
      bib_editor.open

      report('Create bibliographic record.')
      bib_info = Array.new
      bib_info << {:tag => '008', :value => 'BibEditorSmokeTest'}
      bib_info << {:tag => '245', :value => '|aBib Editor Smoke Test'}
      bib_info << {:tag => '100', :value => '|aOLE QA Smoketest'}
      create_bib(bib_editor, bib_info)

      report('Create Instance (Holdings) Record.')
      instance_editor = OLE_QA::Framework::OLELS::Instance_Editor.new(@ole)     
      instance_info = {:location => 'B-EDUC/BED-STACKS',
        :call_number => OLE_QA::Tools::Data_Factory::Bib_Factory.call_number,
        :call_number_type => 'LCC'}
      create_instance(instance_editor, instance_info)
      
      report('Create Item Record.')
      item_editor = OLE_QA::Framework::OLELS::Item_Editor.new(@ole)
      unless instance_editor.item_link.present?
        instance_editor.holdings_icon.click
        instance_editor.item_link.wait_until_present
      end
      instance_editor.item_link.click
      item_editor.wait_for_page_to_load

      report('Set Barcode',1)
      item_barcode = OLE_QA::Tools::Data_Factory::Bib_Factory.barcode
      item_editor.barcode_field.when_present.set(item_barcode)
      report(item_editor.barcode_field.value,2)

      report('Set Item Status.',1)
      item_editor.item_status_selector.when_present.select('Available')
      report(item_editor.item_status_selector.value,2)

      report('Set Item Type.',1)
      item_editor.item_type_selector.when_present.select('book')
      report(item_editor.item_type_selector.value,2)

      report('Save record.',1)
      save_msg = item_editor.save_record
      report(save_msg,2)

      report('Return to main menu.')
      @ole.open
    end
  end
end
