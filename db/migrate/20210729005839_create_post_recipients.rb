class CreatePostRecipients < ActiveRecord::Migration[6.1]
  def change
    create_table :post_recipients do |t|
      t.belongs_to :recipient, references: :users
      # 이렇게 하면 add_foreign_key가 생성되지 않음, 혹시 index: true를 넣으면 생성될 것인가?
      t.belongs_to :post, index: true

      t.timestamps
    end
  end
end
