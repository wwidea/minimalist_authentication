module MinimalistAuthentication
  class NullPassword
    # does not match any object
    def ==(object)
      false
    end
  end
end
