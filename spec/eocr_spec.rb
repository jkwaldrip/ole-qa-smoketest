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

describe 'The EOCR module' do
  before :all do
    @eocr = OLE_QA::Smoketest::EOCR.new
  end
  
  it 'should have a list of filenames' do
    @eocr.file_names.should be_an(Array)
    @eocr.file_names.count.should > 0
  end

  it 'should have a list of EDI files' do
    @eocr.edi_files.should be_an(Array)
    @eocr.edi_files.each {|filename| filename.should =~ /\.edi/}
  end

  it 'should have a list of MRC files' do
    @eocr.mrc_files.should be_an(Array)
    @eocr.mrc_files.each {|filename| filename.should =~ /\.mrc/}
  end

  it 'should return a file selector array' do
    files = @eocr.select_files
    files.should be_an(Array)
    files.count.should eq(3)
    files[0].should_not =~ /.mrc/
    files[0].should_not =~ /.edi/
    File.exist?(files[1]).should be_true
    File.exist?(files[2]).should be_true
  end

  it 'should destructively return a file selector array' do
    mrc_count = @eocr.mrc_files.count
    edi_count = @eocr.edi_files.count
    files = @eocr.select_files!
    mrc_count.should eq(@eocr.mrc_files.count + 1)
    edi_count.should eq(@eocr.edi_files.count + 1)
  end
end