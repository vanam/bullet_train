require "test_helper"

class TwoFactorAuthentication < ActionDispatch::IntegrationTest
  if two_factor_authentication_enabled?
    def setup
      @jane = FactoryBot.create :two_factor_user, first_name: "Jane", last_name: "Smith"
      @john = FactoryBot.create :user, first_name: "John", last_name: "Smith"
    end

    @@test_devices.each do |device_name, display_details|
      test "a user can log in with a valid OTP on a #{device_name}" do
        resize_for(display_details)

        visit new_user_session_path
        assert page.has_content?("Sign In")

        fill_in "Your Email Address", with: @jane.email
        click_on "Next"
        fill_in "Your Password", with: @jane.password
        fill_in "Two-Factor Authentication Code", with: @jane.otp.now

        click_on "Sign In"

        assert page.has_content?("Dashboard")
      end

      test "a user cannot log in with an invalid OTP a #{device_name}" do
        resize_for(display_details)

        visit new_user_session_path
        assert page.has_content?("Sign In")

        fill_in "Your Email Address", with: @jane.email
        click_on "Next"
        fill_in "Your Password", with: @jane.password
        fill_in "Two-Factor Authentication Code", with: "000000"

        click_on "Sign In"

        refute page.has_content?("Dashboard")
      end

      test "OTP input is invisible to a user with OTP authentication disabled on a #{device_name}" do
        resize_for(display_details)

        visit new_user_session_path
        assert page.has_content?("Sign In")

        fill_in "Your Email Address", with: @john.email
        click_on "Next"
        fill_in "Your Password", with: @john.password

        refute page.has_content?("Two-Factor Authentication Code")
      end
    end
  end
end