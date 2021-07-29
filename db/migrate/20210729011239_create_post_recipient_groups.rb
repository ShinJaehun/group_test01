class CreatePostRecipientGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :post_recipient_groups do |t|
      # t.belongs_to :recipient_group, class_name: :Group, foreign_key: :recipient_group_id
      # 이렇게 하면 add_foreign_key가 생성됨
      # 근데 이렇게 하니까 post_recipient_groups가 아니라 recipient_group을 찾더라...
      # 정확히 알지 못하면 사용하지 말것!
      t.belongs_to :recipient_group, references: :groups
      t.belongs_to :post, index: true

      t.timestamps
    end
  end
end
