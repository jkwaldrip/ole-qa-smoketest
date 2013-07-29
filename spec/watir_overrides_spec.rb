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

require 'rspec'
require 'spec_helper'

describe 'The OLE QA Smoketest Watir overrides' do

  before :all do
    OLE_QA::Smoketest.start(:dry_run? => true, :quiet? => true)
    @wait = OLE_QA::Smoketest.wait
    OLE_QA::Smoketest.framework.open(OLE_QA::Smoketest.url)
  end

  it 'should set the default timeout on the while method' do
    lambda {
      Watir::Wait.while { OLE_QA::Smoketest.session.browser.link(:text => 'Loan').present? }
    }.should raise_error(Watir::Wait::TimeoutError, "timed out after #{@wait} seconds")
  end

  it 'should set the default timeout on the until method' do
    lambda {
      Watir::Wait.until { OLE_QA::Smoketest.session.browser.link(:text => 'Foo').present? }
    }.should raise_error(Watir::Wait::TimeoutError, "timed out after #{@wait} seconds")
  end

  it 'should set the default timeout on wait_until_present' do
    lambda {
      OLE_QA::Smoketest.framework.browser.link(:text => 'Foo').wait_until_present
    }.should raise_error(Watir::Wait::TimeoutError, "timed out after #{@wait} seconds, waiting for {:text=>\"Foo\", :tag_name=>\"a\"} to become present")
  end

  it 'should set the default timeout on wait_while_present' do
    lambda {
      OLE_QA::Smoketest.framework.browser.link(:text => 'Loan').wait_while_present
    }.should raise_error(Watir::Wait::TimeoutError, "timed out after #{@wait} seconds, waiting for {:text=>\"Loan\", :tag_name=>\"a\"} to disappear")
  end

  it 'should set the default timeout on when_present' do
    lambda {
      OLE_QA::Smoketest.framework.browser.link(:text => 'Foo').when_present.click
    }.should raise_error(Watir::Wait::TimeoutError, "timed out after #{@wait} seconds, waiting for {:text=>\"Foo\", :tag_name=>\"a\"} to become present")
  end
end