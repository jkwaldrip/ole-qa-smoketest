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
  # Create an item record then checkout and return that item.
  class CirculationWorkflow < OLE_QA::Smoketest::Script
    self.set_name("Loan/Return Test")
    def run


      report('Open Bib Editor.')
      bib_editor = OLE_QA::Framework::OLELS::Bib_Editor.new(@ole)
      bib_editor.open

      report('Create bibliographic record.')
      report('Set Leader Field.',1)
      bib_editor.set_button.when_present.click

      report('Set Control 008 Field.',1)
      bib_editor.control_008_field.when_present.set('CirculationSmokeTest')
      report(bib_editor.control_008_field.value,2)

      report('Set Marc 245 $a.',1)
      bib_editor.data_line_1.tag_field.when_present.set('245')
      bib_editor.data_line_1.data_field.when_present.set('|aCirculation Smoke Test')
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

      report('Return to OLELS Main Menu.')
      main_menu = OLE_QA::Framework::OLELS::Main_Menu.new(@ole)
      main_menu.open
      report("Login as user \'dev2\'.",1)
      report("Logged in? #{main_menu.login('dev2')}",1)

      report("Open loan screen.")
      loan_screen = OLE_QA::Framework::OLELS::Loan.new(@ole)
      main_menu.loan_link.click
      loan_screen.wait_for_page_to_load
      loan_screen.circulation_desk_selector.select("BL_EDUC")
      loan_screen.circulation_desk_yes.wait_until_present
      loan_screen.circulation_desk_yes.click
      loan_screen.loan_popup_box.wait_while_present

      report("Checkout Item.")
      patron_barcode = "6010570002086988"
      report("Patron Barcode:  #{patron_barcode}",1)
      loan_screen.wait_for_page_to_load
      loan_screen.patron_field.wait_until_present
      loan_screen.patron_field.set("#{patron_barcode}\n")

      report("Enter Item Barcode: #{item_barcode}",1)
      loan_screen.item_field.wait_until_present
      loan_screen.item_field.set("#{item_barcode}\n")
      # The loan pop-up box may appear here with a due date or a circulation desk mismatch warning.
      # Click the loan button only if the loan pop-up box appears.
      if verify {loan_screen.loan_popup_box.present?}
        loan_screen.loan_button.when_present.click
      end
      loan_screen.item_barcode_link(1).wait_until_present
      verify_barcode = loan_screen.item_barcode_link.text.strip == item_barcode
      report("Barcode Verified?  #{verify_barcode}",1)
      due_date = loan_screen.item_due_date(1).text.strip
      report("Due Date: #{due_date}",1)

      report("Checkin Item.")
      loan_screen.return_button.click
      return_screen = OLE_QA::Framework::OLELS::Return.new(@ole)
      Watir::Wait.until { return_screen.item_field.present? }
      now_ish = Chronic.parse('now')
      checkin_date = now_ish.strftime("%m/%d/%Y")
      checkin_time = now_ish.strftime("%k:%m")
      expected_checkin_date = now_ish.strftime("%m/%d/%Y %I:%m %p")
      report("Checkin Date:  #{checkin_date}",1)
      return_screen.checkin_date_field.set(checkin_date)
      report("Checkin Time:  #{checkin_time}",1)
      return_screen.checkin_time_field.set(checkin_time)
      report("Item Barcode:  #{item_barcode}",1)
      return_screen.item_field.set("#{item_barcode}\n")
      if verify {return_screen.checkin_message_box.present?}
        return_screen.return_button.click
        return_screen.checkin_message_box.wait_while_present
      end
      @ole.windows[-1].close if @ole.windows.count > 1
      return_screen.items_returned_toggle.wait_until_present
      verify_return_barcode = return_screen.item_barcode_link(1).text == item_barcode
      report("Barcode Verified?  #{verify_return_barcode}",1)
      verify_return_date = return_screen.item_checkin_date.text == expected_checkin_date
      report("Checkin Date Verified?  #{verify_return_date}",1)

      report("End Circulation Session.")
      return_screen.end_session_button.click
      main_menu.open
      logged_out = main_menu.logout
      report("Logged out? #{logged_out}")
    end
  end
end
