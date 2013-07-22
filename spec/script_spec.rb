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

describe 'The Script class' do

  before :all do
    OLE_QA::Smoketest.start(:dry_run? => true)
  end

  after :all do
    OLE_QA::Smoketest.quit
  end

  it 'should set the name of a test' do
    OLE_QA::Smoketest::Script.set_name('Foo')
    OLE_QA::Smoketest::Script.test_name.should == 'Foo'
    OLE_QA::Smoketest.test_scripts.keys.include?('Foo').should be_true
    OLE_QA::Smoketest.test_scripts.delete('Foo')
  end

  it 'should set a number on the test header if started with multiple scripts' do
    test = OLE_QA::Smoketest::TestScripts::PassExample.new
    expected_header_num = (OLE_QA::Smoketest.test_scripts.keys.sort.index(test.test_name) +1).to_s
    test.header.match(/(^\d+)/).to_s.should == expected_header_num
  end
end