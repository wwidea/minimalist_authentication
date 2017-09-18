class AddUsingDigestVersionToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :using_digest_version, :integer
  end
end
