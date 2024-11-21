# frozen_string_literal: true

module MinimalistAuthentication
  module FormFieldsHelper
    def ma_confirm_password_field(form, options = {})
      form.password_field(
        :password_confirmation,
        options.reverse_merge(
          autocomplete: "new-password",
          minlength:    MinimalistAuthentication.user_model.password_minimum,
          placeholder:  t(".password_confirmation.placeholder"),
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

    def ma_new_password_field(form, options = {})
      form.password_field(
        :password,
        options.reverse_merge(
          autocomplete: "new-password",
          minlength:    MinimalistAuthentication.user_model.password_minimum,
          placeholder:  t(".password.placeholder"),
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
  end
end
