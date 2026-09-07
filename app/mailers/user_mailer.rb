class UserMailer < ApplicationMailer
  def account_activation(user, token)
    @user = user
    @token = token

    mail(
      to: user.email,
      subject: I18n.t("user_mailer.account_activation.subject")
    )
  end

  def password_reset(user, token)
    @user = user
    @token = token

    mail(
      to: user.email,
      subject: I18n.t("user_mailer.password_reset.subject")
    )
  end
end
