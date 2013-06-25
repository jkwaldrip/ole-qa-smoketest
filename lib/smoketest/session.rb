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

    # The options with which the OLE Smoketest session was invoked.
    attr_reader :opts

    # The Selenium::WebDriver::Remote::Capabilities instance, if specified in options.
    attr_reader :caps

    # The target OLE installation's base URL.
    attr_reader :base_url, :fs_url

    # The target OLE installation's OLE Library Systems URL.
    attr_reader :ls_url

    # A unique name for the Smoketest session.
    # - Used for logfiles.
    # - Used for SauceLabs.
    # - Set in @opts[:caps][:name] at instantiation, or else default is used.
    attr_reader :name

    # The Selenium::WebDriver::Driver session.
    attr_accessor :browser

    # @param [Hash] opts The options to pass to the Smoketest session.
    # @param [Hash] opts[:basic] The basic OLE Smoketest session configuration options.
    # @param [Hash] opts[:caps] Configuration options for Selenium::Webdriver browser capabilities.
    # @param [Hash] opts[:sauce] Configuration options for SauceLabs.
    def initialize(opts = {})

      # Parse default options in lib/config/options.yml and merge with specified options.
      default_opts = YAML.load(File.open('lib/config/options.yml'))
      @opts = opts.merge(default_opts)

      # Export options to instance variables.
      @base_url = @opts[:base_url]
      @fs_url = @base_url
      @ls_url = @opts[:ls_url]
      @explicit_wait = @opts[:explicit_wait]
      @implicit_wait = @opts[:implicit_wait]

      # If we're using Selenium::WebDriver::Capabilities, load the appropriate capabilities.
      if @opts[:capabilities?]
        # Set @caps.name to name specified in options + current date & time.
        @opts[:caps][:name] = @opts[:caps][:name] + " (v#{VERSION}) - " + Chronic.parse('now').to_s
        @name = @opts[:caps][:name]
        @caps = Selenium::WebDriver::Remote::Capabilities.send(@opts[:caps])
        @caps.version = @opts[:caps][:version]
        @caps.platform = @opts[:caps][:platform]
        @caps[:name] = @name
      else
        @name = "OLE Smoketest (v#{VERSION}) - #{Chronic.parse('now').to_s}"
      end

      # If we're running on SauceLabs, connect through the appropriate URL.
      # If we're not running on SauceLabs and an existing browser session is given, use that.
      # If we're not running on SauceLabs and no existing browser session is given, create a new session.
      if @opts[:sauce?]
        # Capabilities must be specified if SauceLabs will be used.
        raise StandardError, "Capabilities are required for a SauceLabs session." unless @opts.has_key?(:caps)
        @browser = Selenium::WebDriver::Driver.for(
            :remote,
            :url => "http://#{@opts[:sauce][:username]}:#{@opts[:sauce][:api_key]}@ondemand.saucelabs.com:80/wd/hub",
            :desired_capabilities => @caps
        )
      else
        if @opts[:headless?]
          @headless = Headless.new
          @headless.start
        end
        if @opts[:browser].instance_of?(Selenium::WebDriver::Driver)
          @browser = @opts[:browser]
        else
          @browser = Watir::Browser.new(@opts[:basic][:browser])
          @browser.driver.manage.timeouts.implicit_wait = @opts[:basic][:implicit_wait]
        end
      end
    end

    # Exit the OLE_QA::Smoketest::Session, quitting the browser and destroying the headless session if it exists.
    def quit
      @browser.quit
      @headless.destroy if @opts[:headless?]
    end
  end
end