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
    def run

      report('Open Bib Editor.')
      bib_editor = OLE_QA::Framework::OLELS::Bib_Editor.new(@ole)
      bib_editor.open

      report('Create bibliographic record.')
      report('Set Leader Field.',1)
      bib_editor.set_button.when_present.click

      report('Set Control 008 Field.',1)
      bib_editor.control_008_field.when_present.set('BibEditorSmokeTest')
      report(bib_editor.control_008_field.value,2)

      report('Set Marc 245 $a.',1)
      bib_editor.data_line_1.tag_field.when_present.set('245')
      bib_editor.data_line_1.data_field.when_present.set('|aBib Editor Smoke Test')
      report(bib_editor.data_line_1.data_field.value,2)

      report('Set Marc 100 $a.',1)
      bib_editor.data_line_1.add_button.click
      bib_editor.add_data_line(2)
      bib_editor.data_line_2.tag_field.when_present.set('100')
      bib_editor.data_line_2.data_field.when_present.set('|aOLE QA Smoketest')
      report(bib_editor.data_line_2.data_field.value,2)

      report('Save record.',1)
      save_msg = bib_editor.save_record
      report(save_msg,2)

      report('Create Instance (Holdings) Record.')
      instance_editor = OLE_QA::Framework::OLELS::Instance_Editor.new(@ole)
      bib_editor.holdings_link(1).when_present.click
      instance_editor.wait_for_page_to_load

      report('Set Location.',1)
      instance_editor.location_field.when_present.set('B-EDUC/BED-STACKS')
      report(instance_editor.location_field.value,2)

      report('Set Call Number.',1)
      call_num = OLE_QA::Tools::Data_Factory::Bib_Factory.call_number
      instance_editor.call_number_field.when_present.set(call_num)
      report(instance_editor.call_number_field.value,2)

      report('Set Call Number Type.',1)
      instance_editor.call_number_type_selector.when_present.select_value('LCC')
      report(instance_editor.call_number_type_selector.value,2)

      report('Save record.',1)
      save_msg = instance_editor.save_record
      report(save_msg,2)

      report('Create Item Record.')
      item_editor = OLE_QA::Framework::OLELS::Item_Editor.new(@ole)
      instance_editor.holdings_icon.click
      instance_editor.item_link.wait_until_present
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
