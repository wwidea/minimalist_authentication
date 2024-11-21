class RemoveVerificationTokenColumnsFromUsers < ActiveRecord::Migration[7.2]
  def change
    remove_column :users, :verification_token, :string
    remove_column :users, :verification_token_generated_at, :datetime, precision: nil
  end
end
