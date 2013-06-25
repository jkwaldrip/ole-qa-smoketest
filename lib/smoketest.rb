#!/usr/bin/env ruby

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
#  limitations under the License

require "headless"
require "watir-webdriver"
require "chronic"
require "optparse"
require "pp"
require "benchmark"


module OLE_QA
  module Smoketest

    dir = File.expand_path(File.dirname(__FILE__))
    $LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir)

    Dir["#{File.dirname(__FILE__)}/*/*.rb"].each {|file| require file}
    Dir["#{File.dirname(__FILE__)}/*/*/*.rb"].each {|file| require file}

    # The main Smoketest Session Handling class.
    # @param [Hash]opts the options to pass to the Smoketest session.
    # @option opts [Hash] :basic basic OLE Smoketest session options
    # @option basic [Symbol] :browser the browser to specify for WebDriver
    # @option basic [String] :base_url the OLE installation's base URL
    # @option basic [String] :ls_url the OLE installation's OLE Library System (Rice 2) URL
    # @option basic [Fixnum] :explicit_wait the wait period to be used by the OLE Smoketest
    # @option basic [Fixnum] :implicit_wait the wait period to be passed to Selenium WebDriver
    # @option basic [Boolean] :headless? use the Headless gem to handle a local XVFB session
    # @option basic [Boolean] :capabilities? use Selenium::WebDriver::Remote::Capabilities
    # @option basic [Boolean] :sauce? use SauceLabs (if true, headless? will be ignored, :caps will be required)
    # @option opts [Hash] :caps Selenium Webdriver Capabilities options
    # @option caps [Fixnum] :version the browser version number
    # @option caps [String] :platform the platform to run the browser on
    # @options caps [String] :name the name of the test
    # @option opts [Hash] :sauce SauceLabs connection options
    # @option sauce [String] :username the SauceLabs username
    # @option sauce [String] :api_key the SauceLabs api_key
    # @raise StandardError if opts[:sauce?] is true but opts[:caps] is not specified.
    class Session

      # The options with which the OLE Smoketest session was invoked.
      attr_accessor :opts

      # The Selenium::WebDriver::Remote::Capabilities instance, if specified in options.
      attr_accessor :caps

      # The target OLE installation's base URL.
      attr_accessor :base_url

      # The target OLE installation's OLE Library Systems URL.
      attr_accessor :ls_url

      # A unique name for the Smoketest session.
      # - Used for logfiles.
      # - Used for SauceLabs.
      # - Set in @opts[:caps][:name] at instantiation, or else default is used.
      attr_accessor :name

      # The Selenium::WebDriver::Driver session.
      attr_accessor :browser

      def initialize(opts = {})

        # Parse default options in lib/config/options.yml and merge with specified options.
        default_opts = YAML.load(File.open('lib/config/options.yml'))
        @opts = opts.merge(default_opts)

        # Export options to instance variables.
        @base_url = @opts[:base_url]
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
            @browser = Selenium::WebDriver::Driver.for(@opts[:basic][:browser])
          end
        end

    end
  end
end