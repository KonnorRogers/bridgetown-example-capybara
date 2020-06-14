# frozen_string_literal: true

require 'capybara_helper'

class NavBarTest < CapybaraTestCase
  def setup
    Capybara.current_driver = Capybara.javascript_driver # :selenium by default
  end

  def test_we_can_visit_page
    visit('/')
  end
end
