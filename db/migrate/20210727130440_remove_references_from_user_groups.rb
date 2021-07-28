class RemoveReferencesFromUserGroups < ActiveRecord::Migration[6.1]
  def change
    remove_reference :user_groups, :users, index: false
    remove_reference :user_groups, :groups, index: false
  end
end
