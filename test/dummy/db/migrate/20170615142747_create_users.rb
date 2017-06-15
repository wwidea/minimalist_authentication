class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.boolean :active
      t.string :email
      t.string :crypted_password
      t.string :salt
      t.integer :using_digest_version
      t.datetime :last_logged_in_at

      t.timestamps
    end
  end
end
