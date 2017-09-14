class RemoveUsingDigestVersionFromUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :using_digest_version, :integer
  end
end
