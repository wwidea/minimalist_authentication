module MinimalistAuthentication
  class NullBCryptPassword
    # does not match any object
    def ==(object)
      false
    end
  end
end
