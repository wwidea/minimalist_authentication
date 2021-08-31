class ChangeActiveDefaultToFalseOnUsers < ActiveRecord::Migration[6.1]
  def change
    change_column_default :users, :active, from: nil, to: false
  end
end
