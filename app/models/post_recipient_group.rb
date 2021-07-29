class PostRecipientGroup < ApplicationRecord
  belongs_to :post
  belongs_to :recipient_group, class_name: :Group, foreign_key: :recipient_group_id
end
