class CreateUserGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :user_groups do |t|
      t.belongs_to :users, index: true
      t.belongs_to :groups, index: true

      t.timestamps
    end
  end
end
