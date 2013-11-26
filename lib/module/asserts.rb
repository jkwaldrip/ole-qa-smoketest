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
  # Basic spin asserts and page-reloading asserts for use in test scripts.
  module Asserts
    # The interval at which spin assert statements are run.
    INTERVAL = 0.5

    # The interval at which page-based spin assert statements are run.
    PAGE_INTERVAL = 1

    # A basic spin assert.
    # Use with a block to be evaluated for a true/false response.
    #
    # @example verify {@page.title.text.strip == "Page Title"}
    # @param timeout_in_seconds [Integer] The number of seconds allowed to elapse before the assertion fails.
    def verify(timeout_in_seconds = OLE_QA::Framework.explicit_wait)
      end_time = Time.now + timeout_in_seconds
      until Time.now > end_time
        return true if yield
        sleep INTERVAL
      end
      false
    rescue Watir::Wait::TimeoutError
    end

    # An interrupting spin assert which raises an error if the condition fails.
    # Use with a block to be evaluated for a true/false response.
    #
    # @example assert {@page.title.text.strip == "Page Title"}
    # @param timeout_in_seconds [Integer] The number of seconds allowed to elapse before the assertion fails.
    def assert(timeout_in_seconds = OLE_QA::Framework.explicit_wait)
      end_time = Time.now + timeout_in_seconds
      until Time.now > end_time
        return true if yield
        sleep INTERVAL
      end
      raise OLE_QA::Smoketest::Error, "Assertion failed."
    rescue Watir::Wait::TimeoutError
    end

    # A spin assert which reloads the given page while the condition is not true.
    # - Use for lambda evaluation as in a regular spin assert.
    # - It may be helpful to include a .wait_for_page_to_load statement in the lambda.
    # - Use page_url parameter if the current URL is not the URL to reload (as with newly saved PURAP documents).
    # @param page_url [String] The URL to load if the condition in the lambda fails.
    # @param timeout_in_seconds [Fixnum] The timeout on the assertion, in seconds.
    # @param ole_session [Object] The OLE_QA::Framework session where the browser object can be found.
    def verify_page(page_url = '', timeout_in_seconds = OLE_QA::Framework.doc_wait, ole_session = @ole)
      end_time = Time.now + timeout_in_seconds
      ole_session.browser.goto(page_url) unless page_url.empty?
      until Time.now > end_time
        return true if yield
        sleep PAGE_INTERVAL
        ole_session.browser.refresh
      end
      false
    rescue Watir::Wait::TimeoutError
    end
    alias_method(:page_verify,:verify_page)

    # An interrupting page assert which raises an error if the condition does not evaluate as true before the timeout expires.
    # - Use for lambda evaluation as in a regular spin assert.
    # - It may be helpful to include a .wait_for_page_to_load statement in the lambda.
    # - Use page_url parameter if the current URL is not the URL to reload (as with newly saved PURAP documents).
    # - See {OLE_QA::Smoketest::Asserts#verify_page}
    # @param page_url [String] The URL to load if the condition in the lambda fails.
    # @param timeout_in_seconds [Fixnum] The timeout on the assertion, in seconds.
    # @param ole_session [Object] The OLE_QA::Framework session where the browser object can be found.
    def assert_page(page_url = '', timeout_in_seconds = OLE_QA::Framework.doc_wait, ole_session = @ole)
      end_time = Time.now + timeout_in_seconds
      ole_session.browser.goto(page_url) unless page_url.empty?
      until Time.now > end_time
        return true if yield
        sleep PAGE_INTERVAL
        ole_session.browser.refresh
      end
      raise OLE_QA::Smoketest::Error, "Assertion failed."
    rescue Watir::Wait::TimeoutError
    end
    alias_method(:page_assert,:assert_page)
  end
end