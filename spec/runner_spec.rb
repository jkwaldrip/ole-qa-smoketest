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

describe 'The Smoketest Runner class' do

  before :all do
    OLE_QA::Smoketest.start(:dry_run? => true, :quiet? => true)
  end

  after :all do
    OLE_QA::Smoketest.quit
  end

  it 'should run a single example test script' do
    test = OLE_QA::Smoketest::Runner.run('Pass Example')
    test.results[:outcome].should be_true
  end

  it 'should run all test scripts' do
    test_names = OLE_QA::Smoketest::Runner.run
    test_names.sort.should == OLE_QA::Smoketest.test_scripts.keys.sort
  end
end