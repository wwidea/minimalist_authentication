class RenameUsersPasswordHashToPasswordDigest < ActiveRecord::Migration[7.2]
  def change
    rename_column :users, :password_hash, :password_digest
  end
end
