class Post < ApplicationRecord
  validates :content, presence: { message: '내용을 입력하세요' }, length: { maximum: 200 }
  validates :user_id, presence: true

  # belongs_to :user, :counter_cache => :posts_count
  belongs_to :user

  has_many :post_recipients, dependent: :destroy
  has_many :post_recipient_groups, dependent: :destroy
end
