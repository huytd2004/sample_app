require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  self.fixture_table_names = []

  def setup
    @user = User.create!(
      name: "Example User",
      email: "user@example.com",
      password: "foobar",
      password_confirmation: "foobar"
    )
  end

  test "account_activation" do
    mail = UserMailer.account_activation(@user, @user.activation_token)

    assert_equal I18n.t("user_mailer.account_activation.subject"), mail.subject
    assert_equal [ @user.email ], mail.to
    assert_match @user.activation_token, mail.body.encoded
  end

  test "password_reset" do
    @user.create_reset_digest
    mail = UserMailer.password_reset(@user, @user.reset_token)

    assert_equal I18n.t("user_mailer.password_reset.subject"), mail.subject
    assert_equal [ @user.email ], mail.to
    assert_match @user.reset_token, mail.body.encoded
  end
end
