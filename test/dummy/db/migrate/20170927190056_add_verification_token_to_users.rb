class AddVerificationTokenToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :verification_token, :string
    add_index :users, :verification_token, unique: true
    add_column :users, :verification_token_generated_at, :datetime
  end
end
