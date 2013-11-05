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
  # Test Select & Acquire PURAP Document Workflow from requisition to payment request.
  class PurapWorkflow < OLE_QA::Smoketest::Script
    self.set_name("PURAP Workflow Test")
    include OLE_QA::Smoketest::MixIn::MarcEditor
    def run
      report("Open new requisition.",1)
      requisition = OLE_QA::Framework::OLEFS::Requisition.new(@ole)
      requisition.open

      report("Set description to #{@test_name}.",1)
      requisition.description_field.set(@test_name)

      report("Set delivery building & room number.",1)
      requisition.delivery_tab_toggle.click
      requisition.building_search_icon.wait_until_present
      requisition.building_search_icon.click

      report("Building search.",2)
      building_lookup = OLE_QA::Framework::OLEFS::Building_Lookup.new(@ole)
      building_lookup.wait_for_page_to_load
      building_lookup.building_name_field.set("Wells Library")
      building_lookup.search_button.click
      building_lookup.wait_for_page_to_load
      building_lookup.set_element(:search_result) {building_lookup.browser.td(:text => "Wells Library").parent.td(:index => 0).a}
      verify {building_lookup.search_result.present?}
      building_lookup.search_result.click

      report("Return to requisition",2)
      requisition.wait_for_page_to_load
      requisition.room_field.set("100")

      report("Verify building name & room number.",2)
      verify {requisition.closed_building_field.text.include?("Wells Library")}
      verify {requisition.room_field.text.include?("100")}
      requisition.delivery_tab_toggle.click

      report("Select YBP as vendor",1)
      requisition.vendor_tab_toggle.click
      requisition.vendor_search_icon.wait_until_present
      requisition.vendor_search_icon.click

      report("Vendor search.",2)
      vendor_lookup = OLE_QA::Framework::OLEFS::Vendor_Lookup.new(@ole)
      vendor_lookup.wait_for_page_to_load
      vendor_lookup.vendor_name_field.set("YBP")
      vendor_lookup.search_button.click
      vendor_lookup.set_element(:search_result) {vendor_lookup.browser.td(:index => 1).a(:text => "YBP Library Services").parent.parent.td(:index => 0).a}
      verify {vendor_lookup.search_result.present?}
      vendor_lookup.search_result.click

      report("Return to requisition.",2)
      requisition.wait_for_page_to_load

      report("Verify vendor.",2)
      verify {requisition.closed_vendor_name_field.text.include?("YBP Library Services")}
      requisition.vendor_tab_toggle.click

      report("Add a minimum-requirements bib record.",1)
      requisition.new_bib_option.set
      requisition.new_bib_button.wait_until_present
      requisition.new_bib_button.click
      @ole.browser.windows[-1].use
      bib_editor = OLE_QA::Framework::OLELS::Bib_Editor.new(@ole)

      bib_info = Array.new
      bib_info << {:tag => '245', :value => '|aTitle of Book'}
      create_bib(bib_editor, bib_info)

      report("Check fields.",2)
      verify {bib_editor.data_line.tag_field.value.include?("245")}
      verify {bib_editor.data_line.data_field.value.include?("|aTitle of Book")}

      report("Check message.",2)
      verify {bib_editor.message.text.include?("successful")}

      report("Close bib editor.",1)
      @ole.browser.windows[-1].close
      @ole.browser.windows[0].use

      report("Set requisition line item data.",1)
      report("List Price - 235.00",2)
      requisition.list_price_field.when_present.set("235.00")

      report("Set location on line item.",1)
      report("Location - B-EDUC/BED-STACKS",2)
      requisition.location_selector.select("B-EDUC/BED-STACKS")

      report("Add line item.",1)
      requisition.add_button.click
      requisition.wait_for_page_to_load

      report("Verify list price.",1)
      verify {requisition.line_item.list_price_field.when_present.value.include?("235.00")}

      report("Set line item 1 accounting line info.",1)
      requisition.line_item.accounting_lines_toggle.click
      requisition.line_item.chart_selector.wait_until_present

      report("Chart - BL",2)
      requisition.line_item.chart_selector.select("BL")

      report("Account Number - 2947494",2)
      requisition.line_item.account_number_field.set("2947494")

      report("Object Field - 7112",2)
      requisition.line_item.object_field.set("7112")

      report("Percentage - 100.00",2)
      requisition.line_item.percent_field.set("100")

      report("Add accounting line.",1)
      requisition.line_item.add_account_button.click
      requisition.line_item.accounting_line.chart_selector.wait_until_present

      report("Verify accounting line.",1)

      report("Chart",2)
      verify {requisition.line_item.accounting_line.chart_selector.selected?("BL")}

      report("Account Number",2)
      verify {requisition.line_item.accounting_line.account_number_field.value.include?("2947494")}

      report("Object",2)
      verify {requisition.line_item.accounting_line.object_field.value.include?("7112")}

      report("Percentage",2)
      verify {requisition.line_item.accounting_line.percent_field.value.include?("100.00")}

      report("Add a phone number to Additional Institutional Info.",1)
      requisition.additional_info_tab_toggle.click
      requisition.additional_info_phone_number_field.wait_until_present
      requisition.additional_info_phone_number_field.set("812-555-5555")
      requisition.additional_info_tab_toggle.click

      report("Submit requisition.")
      requisition.submit_button.click
      requisition.wait_for_page_to_load
      requisition.generic_message.wait_until_present

      assert {requisition.submit_message.present?}

      report("Check for PO link.")

      report("Set requisition URL.",1)
      req_doc_id = requisition.document_id.text.strip
      req_url = @ole.fs_url + OLE_QA::Tools::URLs.requisition(req_doc_id)

      report("Requisition Doc #: #{req_doc_id}")

      report("Get PO URL.",1)
      report("Wait for requisition to reach \'Closed\' status.",2)
      assert_page(req_url) {requisition.wait_for_page_to_load
                                requisition.document_type_status.text.include?("Closed")}


      report("Wait for PO link to have a valid number.",2)
      assert_page(req_url) {requisition.wait_for_page_to_load
                                requisition.view_related_tab_toggle.click
                                requisition.view_related_po_link.wait_until_present
                                requisition.view_related_po_link.text =~ /[0-9]+/}

      report("Retrieve URL from View Related tab.",2)
      requisition.view_related_po_link.wait_until_present

      po_id = requisition.view_related_po_link.text.strip
      po_url = requisition.view_related_po_link.href

      report("PO #: #{po_id}")

      report("Open purchase order.")
      @ole.browser.goto(po_url)

      purchase_order = OLE_QA::Framework::OLEFS::Purchase_Order.new(@ole)
      purchase_order.wait_for_page_to_load

      report("Verify purchase order.",1)
      assert {purchase_order.document_type_id.text.include?(po_id)}

      po_doc_id = purchase_order.document_id.text.strip
      report("PO Doc #: #{po_doc_id}")

      po_total = purchase_order.grand_total_field.text.strip

      # FIXME - Re-enable the receiving section (below) when a fix has been found.
      # report("Receive purchase order.")
      # verify {purchase_order.receiving_button.present?}
      # purchase_order.receiving_button.click

      # receiving_doc = OLE_QA::Framework::OLEFS::Receiving_Document.new(@ole)
      # receiving_doc.create_receiving_line(1)
      # receiving_doc.wait_for_page_to_load

      # report("Verify receiving line fields.",1)
      # receiving_doc.receiving_line.description_field.wait_until_present
      # verify {receiving_doc.receiving_line.item_received_quantity_field.text.include?("1")}
      # verify {receiving_doc.receiving_line.item_received_parts_field.text.include?("1")}

      # report("Submit receiving document.")
      # receiving_doc.submit_button.click
      # receiving_doc.wait_for_page_to_load
      # assert {receiving_doc.submit_message.present?}

      # report("Receiving Doc #: #{receiving_doc.document_id.text.strip}")

      report('Create invoice.')
      invoice = OLE_QA::Framework::OLEFS::Invoice.new(@ole)
      invoice.open
  
      invoice.description_field.when_present.set(@test_name)
      report("Description:  #{@test_name}",1)
      invoice.vendor_selector.when_present.select('YBP Library Services')
      report('Vendor:  YBP Library Services',1)
      invoice_date = Chronic.parse('now').strftime("%m\/%d\/%Y")
      invoice.invoice_date_field.when_present.set(invoice_date)
      report("Invoice Date:  #{invoice_date}",1)
      invoice.vendor_invoice_amt_field.when_present.set(po_total)
      report("Invoice Amount:  #{po_total}",1)
      invoice.payment_method_selector.when_present.select('Check')
      report("Payment Method:  Check",1)

      report('Add PO to Invoice.')
      invoice.po_number_field.when_present.set(po_id + "\n")
      report("PO Number Field:  #{po_id}",1)
      invoice.wait_for_page_to_load
      invoice.po_line.add_button.when_present.click
      invoice.current_items_line.line_number = 5
      assert    {invoice.current_items_line.po_number.when_present.text == po_id}
      report("PO added.",1)

      report('Approve invoice.')
      invoice_id = invoice.document_id.when_present.text
      invoice.approve_button.when_present.click
      report('Wait for invoice to reach department-approved status.',1)
      invoice_url = @ole.url + OLE_QA::Tools::URLs.invoice(invoice_id)
      assert_page(invoice_url)  { invoice.document_type_status.when_present.text == 'Department-Approved'}
      report("Invoice Status:  #{invoice.document_type_status.text}")
      report('Return to main menu.')
      @ole.open

    end
  end
end
