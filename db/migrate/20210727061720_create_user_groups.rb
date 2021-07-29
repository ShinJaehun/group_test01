class CreateUserGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :user_groups do |t|
      t.belongs_to :users, index: true
      t.belongs_to :groups, index: true
      # index 때문인지 이렇게 하면 add_foreign_key가 생성됨

      t.timestamps
    end
  end
end
