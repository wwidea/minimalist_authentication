# frozen_string_literal: true

module MinimalistAuthentication
  module ApplicationHelper
    def ma_change_email_link
      link_to("Change", edit_email_path)
    end

    def ma_confirm_password_field(form, options = {})
      form.password_field(
        :password_confirmation,
        options.reverse_merge(
          autocomplete: "new-password",
          minlength:    MinimalistAuthentication.user_model.password_minimum,
          placeholder:  true,
          required:     true
        )
      )
    end

    def ma_email_field(form, options = {})
      form.email_field(
        :email,
        options.reverse_merge(
          autocomplete: "email",
          autofocus:    true,
          placeholder:  t(".email.placeholder", default: true),
          required:     true
        )
      )
    end

    def ma_email_verification_button(**)
      button_to(t(".button"), email_verification_path, **)
    end

    def ma_forgot_password_link
      link_to(t(".forgot_password"), new_password_reset_path)
    end

    def ma_new_password_field(form, options = {})
      form.password_field(
        :password,
        options.reverse_merge(
          autocomplete: "new-password",
          minlength:    MinimalistAuthentication.user_model.password_minimum,
          placeholder:  "New password",
          required:     true
        )
      )
    end

    def ma_password_field(form, options = {})
      form.password_field(
        :password,
        options.reverse_merge(
          autocomplete: "current-password",
          placeholder:  true,
          required:     true
        )
      )
    end

    def ma_skip_link
      link_to("Skip", login_redirect_to)
    end

    def ma_username_field(form, options = {})
      form.text_field(
        :username,
        options.reverse_merge(
          autocomplete: "username",
          autofocus:    true,
          placeholder:  true,
          required:     true
        )
      )
    end

    def ma_verification_message(user = current_user)
      render(user.email_verified? ? "verified" : "unverified")
    end
  end
end
