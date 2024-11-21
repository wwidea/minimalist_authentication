# frozen_string_literal: true

module MinimalistAuthentication
  module FormFieldsHelper
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
