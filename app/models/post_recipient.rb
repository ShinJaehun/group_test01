class PostRecipient < ApplicationRecord
  belongs_to :post
  belongs_to :recipient, class_name: :User, foreign_key: :recipient_id, optional: true
  belongs_to :recipient_group, class_name: :UserGroup, foreign_key: :recipient_group_id, optional: true

  # recipient_id/recipient_group_id 이렇게 운영하기 보다
  # recipient_id/recipient_type 이런 식으로 운영하는 건 어떨까?
  # 아니면 PostRecipient와 PostRecipientGroup 이런 식으로 운영하는 건 어떨까?
end
