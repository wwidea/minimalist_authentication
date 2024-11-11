class RemoveVerificationTokenIndexFromUsers < ActiveRecord::Migration[7.2]
  def change
    remove_index :users, :verification_token, unique: true
  end
end
