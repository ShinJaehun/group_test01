class AddStateToUserGroup < ActiveRecord::Migration[6.1]
  def change
    add_column :user_groups, :state, :string
  end
end
