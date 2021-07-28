class AddReferenceToUserGroups < ActiveRecord::Migration[6.1]
  def change
    add_reference :user_groups, :user, foreign_key: true
    add_reference :user_groups, :group, foreign_key: true
  end
end
