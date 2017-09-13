module MinimalistAuthentication
  class NullBCryptPassword

    # does not match any object
    def ==(object)
      false
    end

    # make cost 0
    def cost
      0
    end

  end
end
