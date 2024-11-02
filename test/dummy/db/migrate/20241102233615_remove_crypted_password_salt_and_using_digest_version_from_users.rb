class RemoveCryptedPasswordSaltAndUsingDigestVersionFromUsers < ActiveRecord::Migration[7.2]
  def change
    remove_column :users, :crypted_password, :string
    remove_column :users, :salt, :string
    remove_column :users, :using_digest_version, :integer
  end
end
