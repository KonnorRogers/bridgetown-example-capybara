# frozen_string_literal: true

require 'capybara_helper'

class SecondTest < CapybaraTestCase
  def setup
    # Capybara.current_driver = Capybara.javascript_driver
  end

  def test_we_can_visit_page
    visit('/')
    sleep 2
    visit('/about')
    sleep 2
  end
end
