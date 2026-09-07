# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/account_activation
  def account_activation
    user = User.first || User.new(name: "Example User", email: "user@example.com")

    UserMailer.account_activation(user, User.new_token)
  end
end
