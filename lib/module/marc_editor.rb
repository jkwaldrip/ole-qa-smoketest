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
  module MixIn  

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
      # Create a Marc bibliographic record.
      # @param [Object] editor_page The actual bib editor page object instantiated from the OLE_QA::Framework session.
      # @param [Array] bib_ary  The array containing keyed hashes for Marc bib record lines.
      #
      # - Example input:
      #   [ {:tag => '008',
      #      :value => 'ControlFieldRandomText'},
      #     {:tag => '245',
      #     :ind1 => '0',
      #     :ind2 => '0',
      #     :value => '|aTesting Bib Editor'},
      #     {:tag => '100',
      #     :ind1 => '',
      #     :ind2 => '',
      #     :value => '|aOLE QA Smoketest'}
      #   ]
      def create_bib(editor_page, bib_ary)
        # Gather control field lines from array.
        control_lines = bib_ary.select { |marc_line| ('001'..'008').include?(marc_line[:tag]) }
        bib_ary.delete_if { |marc_line| ('001'..'008').include?(marc_line[:tag]) }

        # Wait for the actual bib editor to load.
        # - This may be superfluous, but better to lose at races than lose at Selenium.
        report('Wait for Bib Editor to load.',1)
        editor_page.wait_for_page_to_load

        # Click the 'Set Leader Field' button.
        report('Set leader field.',1)
        editor_page.set_button.when_present.click

        # Set control fields individually.
        # - This could be made iterative, but the challenge introduced by 006 and 007 being repeatable
        #   and the lack of necessity for using repeatable 006 & 007 fields in basic smoketesting
        #   so far makes this an unnecessary level of complexity.
        # - Only fields 001, 003, 005, 006, 007, and 008 are used at present.  (2013/09/17)
        control_lines.each do |line|
          report("Control #{line[:tag]} Field:  #{line[:value]}",2)
          case line[:tag]
          when '001'
            editor_page.control_001_field.when_present.set(line[:value])
          when '003'
            editor_page.control_003_field.when_present.set(line[:value])
          when '005'
            editor_page.control_005_field.when_present.set(line[:value])
          when '006'
            editor_page.control_006_line_1.field.when_present.set(line[:value])
          when '007'
            editor_page.control_007_line_1.field.when_present.set(line[:value])
          when '008'
            editor_page.control_008_field.when_present.set(line[:value])
          end
        end

        # Enter regular Marc data lines.
        bib_ary.each do |line|
          i = bib_ary.index(line) + 1
          current_line = editor_page.send("data_line_#{i}".to_sym)
          current_line.tag_field.when_present.set(line[:tag])
          current_line.ind1_field.when_present.set(line[:ind1]) unless line[:ind1].nil?
          current_line.ind2_field.when_present.set(line[:ind2]) unless line[:ind2].nil?
          current_line.data_field.when_present.set(line[:value])
          report("Marc Data Line #{i}, Tag:  #{line[:tag]},  Value:  #{line[:value]}",2)
          unless i == bib_ary.count
            current_line.add_button.when_present.click
            editor_page.add_data_line(i + 1)
          end
        end
        
        message = editor_page.save_record
        report(message)
      end
    end
  end
end
