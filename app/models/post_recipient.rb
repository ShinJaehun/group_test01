class PostRecipient < ApplicationRecord
  belongs_to :post
  #belongs_to :recipient, class_name: :User, foreign_key: :recipient_id, optional: true
  #optional을 달면 null 허용(개인에게는 recipient_id, 그룹에는 recipient_group_id 이렇게 적용할 때 사용했었음)
  belongs_to :recipient, class_name: :User
end
