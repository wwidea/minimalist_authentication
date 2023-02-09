# frozen_string_literal: true

module MinimalistAuthentication
  class NullPassword
    # does not match any object
    def ==(_other)
      false
    end
  end
end
