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
  # Test for single upload of paired Marc/EDI electronic order batch files.
  class StaffUpload < OLE_QA::Smoketest::Script
    self.set_name('Staff Upload Test')

    def run
      report('Fetch EOCR data.')
      eocr_factory = OLE_QA::Smoketest::EOCR.new
      eocr = eocr_factory.select_files
      report("Bare Filename:  #{eocr[0]}",1)
      report("File Load Path: #{eocr_factory.file_path}",1)
      now_ish = Chronic.parse('now').strftime('%Y/%m/%d %H:%k %Z')
      upload_desc = "Smoketest #{now_ish} -- " + eocr[0]

      report('Open Staff Upload screen.')
      upload_screen = OLE_QA::Framework::OLELS::Staff_Upload.new(@ole)
      upload_screen.open
      report('Enter Marc file.',1)
      upload_screen.marc_field.when_present.set(eocr[1])
      report('Enter EDI file.',1)
      upload_screen.edi_field.when_present.set(eocr[2])
      report('Select YBP profile.',1)
      upload_screen.profile_selector.when_present.select('YBP')
      report("Enter Description:  #{upload_desc}",1)
      upload_screen.description_field.when_present.set(upload_desc)
      report('Click upload.',1)
      today = Chronic.parse('now').strftime('%m/%d/%Y')
      outcome_message = upload_screen.upload
      report('Upload Result:',1)
      report(outcome_message,2)
      raise StandardError, "Upload not successful.\n#{outcome_message}" unless outcome_message =~ /successfully/

      report('Return to OLE Financial System Main Menu.')
      main_menu = OLE_QA::Framework::OLEFS::Main_Menu.new(@ole)
      main_menu.open

      report('Open Load Summary Lookup screen.')
      lookup = OLE_QA::Framework::OLEFS::Load_Summary_Lookup.new(@ole)
      report('Trying search.',1)
      i = 1
      page_assert('',90) {
        lookup.open
        lookup.wait_for_page_to_load
        lookup.description_field.when_present.set(upload_desc)
        lookup.date_from_field.when_present.set(today)
        lookup.search_button.click
        lookup.wait_for_page_to_load
        i += 1
        lookup.b.table(:id => 'row').present?
      }
      report("Attempted search #{i} times.",2)

      report("Results present?  #{lookup.row_by_text(upload_desc).present?}")
      load_report_id = lookup.doc_link_by_text(upload_desc).text.strip
      report("Load Report ID:  #{load_report_id}",1)

      report('Open load report.')
      load_report_url = @ole.base_url + OLE_QA::Tools::URLs.load_report(load_report_id)
      load_report = OLE_QA::Framework::OLEFS::Load_Report.new(@ole)
      i = 1
      page_assert('',90) {
        @ole.open(load_report_url)
        load_report.wait_for_page_to_load
        i += 1
        load_report.counts.text.match(/TOTAL\:\s+\d+.*\sSUCCESS\:\s+\d+.*FAILED\:\s+\d+/)
      }
      report("Load report open attempted #{i} times.",2)

      total_count = load_report.total_count
      success_count = load_report.success_count
      failure_count = load_report.failure_count
      report("Total:        #{total_count}",1)
      report("Success:      #{success_count}",1)
      report("Failure:      #{failure_count}",1)

      report('Return to main menu.')
      main_menu.open
    end
  end
end