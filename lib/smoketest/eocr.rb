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
  # A class for handling EOCR filepaths.
  class EOCR

    # The path to the available EOCR files - needed for upload.
    attr_reader :file_path

    # A list of available files without extensions.
    attr_reader :file_names

    # A list of available EDI files for upload.
    attr_reader :edi_files

    # A list of available MRC files for upload.
    attr_reader :mrc_files

    def initialize
      @file_path  = File.expand_path(OLE_QA::Smoketest::DataDir + '/eocr/')
      @file_names = Dir[@file_path + '/mrc/*.mrc'].sort.collect { |file_name| file_name.gsub(@file_path + '/mrc/','').gsub('.mrc','') }
      @edi_files  = Dir[@file_path + '/edi/*.edi'].sort
      @mrc_files  = Dir[@file_path + '/mrc/*.mrc'].sort
    end

    # Return a single filename from the list of bare filenames.
    def select_files
      get_file
    end

    # Return a bare filename, a Marc file (with path), and an EDI file (with path),
    #   removing each from their respective lists to eliminate duplicate uploads.
    def select_files!
      files_out = get_file
      file_name = files_out[0]
      @file_names.delete_if {|element| element =~ /^#{file_name}$/}
      @mrc_files.delete_if  {|element| element =~ /#{file_name}\.mrc$/}
      @edi_files.delete_if  {|element| element =~ /#{file_name}\.edi$/}
      files_out
    end

    private

    # Non-destructively select a filename and return the MRC and EDI files matching the name.
    # - Used by .select_file & .select_file!
    def get_file
      files_out = Array.new
      file_name = @file_names.sample
      files_out << file_name
      @mrc_files.each {|element| files_out << element if element =~ /#{file_name}\.mrc$/}
      @edi_files.each {|element| files_out << element if element =~ /#{file_name}\.edi$/}
      files_out
    end
  end
end