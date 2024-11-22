# frozen_string_literal: true

class PasswordExclusivityValidator < ActiveModel::EachValidator
  # Ensure password does not match username or email.
  def validate_each(record, attribute, value)
    %w[username email].each do |field|
      record.errors.add(attribute, "can not match #{field}") if value.casecmp?(record.try(field))
    end
  end
end
