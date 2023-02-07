# frozen_string_literal: true

module MinimalistAuthentication
  module Conversions
    class MergePasswordHash

      class << self
        def run!
          user_model.where(using_digest_version: 3, password_hash: nil).each do |user|
            new(user).update!
          end
        end

        private

        def user_model
          MinimalistAuthentication.configuration.user_model
        end
      end

      attr_accessor :user

      delegate :salt, :crypted_password, to: :user

      def initialize(user)
        self.user = user
      end

      def update!
        user.update_column(:password_hash, merged_password_hash)
      end

      private

      def merged_password_hash
        "#{salt}#{crypted_password}"
      end
    end
  end
end
