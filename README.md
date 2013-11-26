# OLE QA Smoketest

This gem is an automated smoketest application for the [Kuali Open Library Environment](http://www.kuali.org/ole).
It contains a command-line interface (ole-qa-smoketest/ole-smoketest.rb), and relies on the
[OLE QA Framework](http://www.github.com/jkwaldrip/ole-qa-framework) to supply element definitions in a page-object
model.

## Command-Line Usage

    ./ole-smoketest.rb -hvqtsL -l [FILENAME] -n NAME -b BROWSER -B VERSION -p OS -U UNAME -K KEY
        -w NN -T 'Test Name'

    -h/--help
        Print the help screen and exit.

    -v/--version
        Print the version number and exit.

    -q/--quiet-mode
        Run the smoketest in quiet mode.
        (Suppress command-line output.)

    -t/--timestamp
        Use timestamps in output.  (Defaults to no.)

    -s/--sauce-labs
        Use SauceLabs connection.  (Default connection info is set in 'lib/config/options.yml'.)

    -L/--ls
        List all test scripts in 'scripts/'.

    -l/--log [FILENAME]
        Log the testing session instead of writing to STDOUT.  Optionally specify the filename.
        (Defaults to 'logs/Smoketest-YYYY-MM-DD-HHMM.log'.)

    -n/--name NAME
        Specify the name for the testing session.  This appears at the head of the logfile, and more
        importantly, sets the name to be used when referring to the testing session on SauceLabs.
        (Defaults to 'OLE Smoketest (vX.Y.Z) YYYY-MM-DD-HHMM'.)

    -b/--browser BROWSER
        Set the browser to be used for the testing session.  Only one browser can be specified per
        instance.  This is best supported by a SauceLabs session.

    -B/--browser-version VERSION
        Set the version of the browser to be used.  This option is passed to a new session of
        Selenium WebDriver Remote Capabilities.

    -p/--platform OS
        Set the operating system platform to be used.  This option is passed to a new session of
        Selenium WebDriver Remote Capabilities, and is best supported by a SauceLabs session.

    -U/--sauce-username UNAME
        Set the username to be passed to a SauceLabs connection.  This option is ignored unless
        the -s/--saucelabs switch is specified.

    -K/--sauce-api-key KEY
        Set the API key to be passed to a SauceLabs connection.  This option is ignored unless
        the -s/--saucelabs switch is specified.

    -w/--wait NN
        Set the default explicit wait period (NN seconds) to be used in assert and verify
        statements. This option may not affect longer wait periods, such as the wait period
        specified for an OLE Financial System e-Document to be automatically approved after
        submission.

    -T/--test-script FILENAME.rb
        Run a specific test script by name.
        (Use -L/--ls to get a list of test scripts by name.)


## Dependencies

This gem relies on some additional utilities.

### XVFB

The Virtual Framebuffer X Server [XVFB](http://www.x.org/releases/X11R7.6/doc/man/man1/Xvfb.1.xhtml) provides
headless browser testing for this gem.  XVFB session-handling relies on the [Headless](https://github.com/leonid-shevtsov/headless) gem.

### Watir-Webdriver

[Watir-Webdriver](http://www.watirwebdriver.com) is used to handle Selenium::WebDriver sessions.  Watir-Webdriver requires
the [Selenium 2](http://docs.seleniumhq.org/docs/03\_webdriver.jsp) server to perform browser automation.

### SauceLabs

An account is required for [SauceLabs](http://saucelabs.com) functionality.  Supply the username and private API key for your
SauceLabs account as indicated in lib/config/options.yml.  These options may also be set on the command-line.

## OLE QA Gem Dependencies

The gems listed in this section are specific to OLE QA Testing, and are hosted on GitHub rather than RubyGems.  This section
is meant to provide a model of how these gems are utilized in this application.

### OLE QA Framework

The [OLE QA Framework](http://www.github.com/jkwaldrip/ole-qa-framework) gem provides a basic page-object model for handling
common elements in the Kuali OLE application.  The actual test scripts executed by the Runner object when this application is
invoked are written in the Watir-Webdriver based language provided by the OLE QA Framework.

The OLE QA Framework is accessible through the same top-level namespace module (OLE\_QA) as the Smoketest Application to
provide more seamless integration between these three related gems.

----
&copy; 2005-2013, The Kuali Foundation.
Released under the [ECLv2 License](http://opensource.org/licenses/ecl2.php).