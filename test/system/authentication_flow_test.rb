require "application_system_test_case"
require "securerandom"

class AuthenticationFlowTest < ApplicationSystemTestCase
  driven_by :rack_test

  test "user can sign up, verify email, log in, and request password reset" do
    email = "test-#{SecureRandom.hex(12)}@example.com"
    password = "Secret12345678!"

    page.driver.post sign_up_path, { email:, password:, password_confirmation: password }
    assert_equal 201, page.status_code

    user = User.find_by!(email: email)
    verification_token = user.generate_token_for(:email_verification)

    page.driver.get identity_email_verification_path(sid: verification_token)
    assert_equal 204, page.status_code

    page.driver.post sign_in_path, { email:, password: }
    assert_equal 201, page.status_code
    token = page.driver.response.headers["X-Session-Token"]
    assert token.present?

    # clear_emails
    assert_emails 1 do
      page.driver.post identity_password_reset_path, { email: }
      assert_equal 204, page.status_code
    end
  end
end
