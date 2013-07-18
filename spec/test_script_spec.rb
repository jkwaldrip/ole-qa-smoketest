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

describe 'A TestScript object' do

  before :all do
    class Example < OLE_QA::Smoketest::TestScript
      def self.run
        true
      end
    end

  end

  it 'should run a test' do
    example = Example.run
    example.should be_true
  end

  it 'should have an OLE Smoketest Session accessor' do
  end

  it 'should have an OLE Framework Session accessor' do

  end
end