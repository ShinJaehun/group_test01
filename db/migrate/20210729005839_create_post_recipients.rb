class CreatePostRecipients < ActiveRecord::Migration[6.1]
  def change
    create_table :post_recipients do |t|
      #t.belongs_to :recipient, class_name: :User, foreign_key: :recipient_id
      #t.belongs_to :recipient, class_name: :User, foreign_key: :user_id

      t.belongs_to :recipient, references: :users, index: true
      # index: true 넣어도 변화 없음(add_foreign_key가 생성되지 않음)
      t.belongs_to :post, index: true

      t.timestamps
    end
  end
end
