# frozen_string_literal: true

module MinimalistAuthentication
  module FormFieldsHelper
    def confirm_password_field(form, options = {})
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

    def new_password_field(form, options = {})
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

    def password_reset_email_field(form, options = {})
      form.email_field(
        :email,
        options.reverse_merge(
          autocomplete: "email",
          autofocus:    true,
          placeholder:  t(".placeholder"),
          required:     true
        )
      )
    end
  end
end
