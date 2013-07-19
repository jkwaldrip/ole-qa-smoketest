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

describe 'An OLE Smoketest Test Script' do

  it 'should run without error' do
    OLE_QA::Smoketest::TestScripts::PassExample.new
  end

  it 'should have an outcome in the results hash' do
    pass = OLE_QA::Smoketest::TestScripts::PassExample.new
    fail = OLE_QA::Smoketest::TestScripts::FailExample.new
    pass.results[:outcome].should be_true
    fail.results[:outcome].should be_false
  end

  it 'should be able to access the OLE Smoketest Session' do
    session = OLE_QA::Smoketest::TestScripts::SessionExample.new
    session.results[:outcome].should be_true
  end
end