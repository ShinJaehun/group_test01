class CreatePostRecipients < ActiveRecord::Migration[6.1]
  def change
    create_table :post_recipients do |t|
      t.belongs_to :recipient, references: :users
      t.belongs_to :recipient_group, references: :user_groups
      t.belongs_to :post, index: true

      t.timestamps
    end
  end
end
