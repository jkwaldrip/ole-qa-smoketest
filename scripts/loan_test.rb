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
  # Verify loan and return screens are loading properly and associated with desk & patron data.
  class CirculationWorkflow < OLE_QA::Smoketest::Script
    self.set_name("Loan Test")
    include OLE_QA::Smoketest::MixIn::MarcEditor
    def run
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

      report("Select patron.")
      patron_barcode = OLE_QA::Framework::Patron_Factory.select_patron[:barcode]
      report("Patron Barcode:  #{patron_barcode}",1)
      loan_screen.wait_for_page_to_load
      loan_screen.patron_field.wait_until_present
      loan_screen.patron_field.set("#{patron_barcode}\n")
      loan_screen.item_field.wait_until_present
      report("Item field appears?  #{loan_screen.item_field.present?}")
      
      report("Check return screen")
      loan_screen.return_button.click
      return_screen = OLE_QA::Framework::OLELS::Return.new(@ole)
      Watir::Wait.until { return_screen.item_field.present? }

      report("End Circulation Session.")
      return_screen.end_session_button.click
      main_menu.open
      logged_out = main_menu.logout
      report("Logged out? #{logged_out}")
    end
  end
end
