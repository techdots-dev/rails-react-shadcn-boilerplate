require "application_system_test_case"

class AuthenticationFlowTest < ApplicationSystemTestCase
  driven_by :rack_test

  test "user can sign up, log in, and request password reset" do
    email = "test@example.com"
    password = "secret123"

    page.driver.post sign_up_path, params: { email:, password:, password_confirmation: password }
    assert_equal 201, page.status_code

    page.driver.post sign_in_path, params: { email:, password: }
    assert_equal 201, page.status_code
    token = page.driver.response.headers["X-Session-Token"]
    assert token.present?

    assert_emails 1 do
      page.driver.post identity_password_reset_path, params: { email: }
      assert_equal 200, page.status_code
    end
  end
end