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
    #       create_bib(bib_editor, bib_info)
    #       create_instance(instance_editor, instance_info)
    #       create_item(item_editor, item_info)
    #     end
    #   end
    #
    # - See individual methods for parameter requirements.
    #
    module MarcEditor
      # Create a Marc bibliographic record.
      # @param [Object] bib_editor The actual bib editor page object instantiated from the OLE_QA::Framework.
      # @param [Array] bib_ary  The array containing keyed hashes for Marc bib record lines.
      #
      # - Example Array:
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
      def create_bib(bib_editor, bib_ary)
        # Gather control field lines from array.
        control_lines = bib_ary.select { |marc_line| ('001'..'008').include?(marc_line[:tag]) }
        bib_ary.delete_if { |marc_line| ('001'..'008').include?(marc_line[:tag]) }

        # Wait for the actual bib editor to load.
        # - This may be superfluous, but better to lose at races than lose at Selenium.
        report('Wait for Bib Editor to load.',1)
        bib_editor.wait_for_page_to_load

        # Click the 'Set Leader Field' button.
        report('Set leader field.',2)
        bib_editor.set_button.when_present.click

        # Set control fields individually.
        # - This could be made iterative, but the challenge introduced by 006 and 007 being repeatable
        #   and the lack of necessity for using repeatable 006 & 007 fields in basic smoketesting
        #   so far makes this an unnecessary level of complexity.
        # - Only fields 001, 003, 005, 006, 007, and 008 are used at present.  (2013/09/17)
        control_lines.each do |line|
          report("Control #{line[:tag]} Field:  #{line[:value]}",2)
          case line[:tag]
          when '001'
            bib_editor.control_001_field.when_present.set(line[:value])
          when '003'
            bib_editor.control_003_field.when_present.set(line[:value])
          when '005'
            bib_editor.control_005_field.when_present.set(line[:value])
          when '006'
            bib_editor.control_006_line_1.field.when_present.set(line[:value])
          when '007'
            bib_editor.control_007_line_1.field.when_present.set(line[:value])
          when '008'
            bib_editor.control_008_field.when_present.set(line[:value])
          end
        end

        # Enter regular Marc data lines.
        bib_ary.each do |line|
          i = bib_ary.index(line) + 1
          current_line = bib_editor.send("data_line_#{i}".to_sym)
          current_line.tag_field.when_present.set(line[:tag])
          current_line.ind1_field.when_present.set(line[:ind1]) unless line[:ind1].nil?
          current_line.ind2_field.when_present.set(line[:ind2]) unless line[:ind2].nil?
          current_line.data_field.when_present.set(line[:value])
          report("Marc Data Line #{i}, Tag:  #{line[:tag]},  Value:  #{line[:value]}",2)
          unless i == bib_ary.count
            current_line.add_button.when_present.click
            bib_editor.add_data_line(i + 1)
          end
        end
        
        report('Save bib record.',1)
        message = bib_editor.save_record
        report(message,2)
      end

      # Create a Marc instance/holdings record.
      # @param [Object] instance_editor The actual instance editor page object instantiated from the OLE_QA::Framework.
      # @param [Hash] instance_info  A keyed hash containing the information to enter into the instance record.
      #
      # - Example Hash:
      #   {:location => 'B-EDUC/BED-STACKS',
      #     :call_number => 'PJ1135 .A45 2010',
      #     :call_number_type => 'LCC'
      #     :instance_number => 1}
      #
      #   - :instance_number is the sequential number of the instance record attached to the bib record, starting on 1.
      # 
      def create_instance(instance_editor, instance_info)
        # Set instance number to 1 if not found.
        instance_info[:instance_number] = 1 if instance_info[:instance_number].nil?

        # Open instance record.
        report('Open instance record.',1)
        instance_editor.holdings_link(instance_info[:instance_number]).when_present.click
        instance_editor.wait_for_page_to_load

        report('Set location.',1)
        instance_editor.location_field.when_present.set(instance_info[:location])
        report("Location:  #{instance_info[:location]}",2)

        report('Set Call Number.',1)
        instance_editor.call_number_field.when_present.set(instance_info[:call_number])
        report("Call Number:  #{instance_info[:call_number]}",2)
        instance_editor.call_number_type_selector.when_present.select_value(instance_info[:call_number_type])
        report("Call Number Type:  #{instance_info[:call_number_type]}",2)

        report('Save instance record.',1)
        message = instance_editor.save_record
        report(message,2)
      end

      # Create a Marc item record.
      # @param [Object] item_editor  The Actual item editor page object instantiated from the OLE_QA::Framework.
      # @param [Hash] instance_info  A keyed hash containing the information to enter into the item record.
      #
      # - Example Hash:
      #   {:item_type => 'book',
      #     :item_status => 'Available',
      #     :barcode => '6569660552130812946'}
      #
      #   - :instance_number is the sequential number of the instance record attached to the bib record, starting on 1.
      #   - :item_number is the sequential number of the item record attached to the instance record, starting on 1.
      #
      def create_item(item_editor, item_info)
        # Set instance & item numbers to 1 if not found.
        item_info[:instance_number] = 1 if item_info[:instance_number].nil?
        item_info[:item_number]     = 1 if item_info[:item_number].nil?

        # Open item record.
        unless item_editor.item_link(item_info[:item_number]).present?
          item_editor.holdings_icon(item_info[:instance_number]).when_present.click
          item_editor.item_link(item_info[:item_number]).wait_until_present
        end
        report('Open item record.',1)
        item_editor.item_link(item_info[:item_number]).click
        item_editor.wait_for_page_to_load

        report('Set Item Type.',1)
        item_editor.item_type_selector.when_present.select(item_info[:item_type])
        report("Item Type:  #{item_info[:item_type]}",2)

        report('Set Item Status.',1)
        item_editor.item_status_selector.when_present.select(item_info[:item_status])
        report("Item Status:  #{item_info[:item_status]}",2)

        report('Set Barcode.',1)
        item_editor.barcode_field.when_present.set(item_info[:barcode])
        report("Barcode:  #{item_info[:barcode]}",2)

        report('Save record.',1)
        message = item_editor.save_record
        report(message,2)
      end
    end
  end
end
