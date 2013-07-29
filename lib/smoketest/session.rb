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
  # The main Smoketest Session Handling class.
  class Session

    include OLE_QA::Tools::Asserts

    # The options with which the OLE Smoketest session was invoked.
    attr_reader :opts

    # The Selenium::WebDriver::Remote::Capabilities instance, if specified in options.
    attr_reader :caps

    # The target OLE installation's base URL.
    attr_reader :url
    # URL support for deprecated URL functions in Framework.
    # See {OLE_QA::Framework::Session#url}
    alias_method(:base_url, :url)
    alias_method(:ls_url,   :url)
    alias_method(:fs_url,   :url)

    # A unique name for the Smoketest session.
    # - Used for logfiles.
    # - Used for SauceLabs.
    # - Set in @opts[:caps][:name] at instantiation, or else default is used.
    attr_reader :name

    # The Selenium::WebDriver::Driver session.
    attr_accessor :browser

    # The OLE_QA::Framework session.
    attr_accessor :framework

    # The start date for this session. (YYYY-MM-DD-HHMM)
    attr_reader :date

    # The timeout (in seconds) used by asserts and wait_until_presents.
    attr_reader :explicit_wait

    # The default timeout for Watir-Webdriver.
    attr_reader :implicit_wait

    # @param [Hash] opts The options to pass to the Smoketest session.
    # @option opts [Symbol] :browser The browser to use when starting the Watir-Webdriver session.
    # @option opts [String] :base_url The base URL for the OLE installation to be tested.
    # @option opts [String] :ls_url The Library System/Rice 2 URL for the OLE installation to be tested.
    # @option opts [Integer] :explicit_wait The wait period (in seconds) to be used for spin asserts.
    # @option opts [Integer] :doc_wait The wait period (in seconds) to be used for doc status-based spin asserts.
    # @option opts [Integer] :implicit_wait The wait period (in seconds) to be used by the Watir::Browser session.
    #   (This should almost always be 0.)
    # @option opts [String] :name The name to use for this session.
    #   (Used by :caps and logging.)
    # @option opts [Boolean] :headless? Use headless gem to create an XVFB session?
    #   (Unnecessary if using a SauceLabs session.)
    # @option opts [Boolean] :capabilities? Use Selenium::WebDriver::Remote::Capabilities?
    #   (Required if using a SauceLabs session.)
    # @option opts [Boolean] :sauce? Use a SauceLabs session for testing?
    # @option opts [String] :sauce_username The username to use for the SauceLabs session.
    # @option opts [String] :sauce_api_key The private API key to use for the SauceLabs session.
    # @option opts [Hash] caps Desired capabilities settings for Selenium::WebDriver::Remote::Capabilities.
    #   - :version (Integer) Version number to use.
    #   - :platform (String) The platform string to use.
    #     (e.g. "Windows 7")
    def initialize(opts = {})

      # Parse default options in lib/config/options.yml and merge with specified options.
      default_opts = YAML.load(File.open('lib/config/options.yml'))
      @opts = default_opts.merge(opts)

      # Export options to instance variables.
      @url = @opts[:url]
      @explicit_wait = @opts[:explicit_wait]
      @implicit_wait = @opts[:implicit_wait]
      @name = @opts[:name] + " (v#{VERSION}) " + StartTime

      # If we're using Selenium::WebDriver::Capabilities, load the appropriate capabilities.
      if @opts[:capabilities?]
        @caps = Selenium::WebDriver::Remote::Capabilities.send(@opts[:browser])
        @caps.version = @opts[:version]
        @caps.platform = @opts[:platform]
        @caps[:name] = @name
      end

      # If we're running on SauceLabs, connect through the appropriate URL.
      # If we're not running on SauceLabs and an existing browser session is given, use that.
      # If we're not running on SauceLabs and no existing browser session is given, create a new session.
      if @opts[:sauce?]
        # Capabilities must be specified if SauceLabs will be used.
        raise StandardError, "Capabilities are required for a SauceLabs session." unless @opts.has_key?(:caps)
        @browser = Watir::Browser.new(
            :remote,
            :url => "http://#{@opts[:sauce_username]}:#{@opts[:sauce_api_key]}@ondemand.saucelabs.com:80/wd/hub",
            :desired_capabilities => @caps
        )
      else
        if @opts[:headless?]
          @headless = Headless.new
          @headless.start
        end
        @browser = Watir::Browser.new(@opts[:browser])
        @browser.driver.manage.timeouts.implicit_wait = @opts[:implicit_wait]
      end

      # Start OLE_QA::Framework session.
      framework_options = @opts
      framework_options[:browser] = @browser
      @framework = OLE_QA::Framework::Session.new(framework_options)

      # Open logfile if logging enabled.
      if @opts[:logging?]
        report("--START--")
        report("Target URL:  #{@framework.url}")
        report(@name)
       end
    end

    # Write a string to the command-line or logfile (if logging is enabled).
    # @param string [String] The string to write.
    # @param hash_indent [Integer] The number of hashmarks to optionally append to the beginning of the string.
    def report(string, hash_indent=0)
      if hash_indent > 0
        string = " " + string
        hash_indent.times {string = '#' + string}
      end
      string = Time.new.strftime("%H:%M:%S ") + string if @opts[:timestamp?]
      if @opts[:logging?] then
        logfile = File.open('logs/' + @opts[:logfile], 'a')
        logfile.puts(string)
        logfile.close
      else
        puts(string) unless @opts[:quiet?]
      end
    end

    # Exit the OLE_QA::Smoketest::Session, quitting the browser and destroying the headless session if it exists.
    def quit
      @browser.quit
      @headless.destroy if @opts[:headless?] && !@opts[:sauce?]
      if @opts[:logging?]
        report("--END--")
      end
    end
  end
end