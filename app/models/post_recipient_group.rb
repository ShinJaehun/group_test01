class PostRecipientGroup < ApplicationRecord
  belongs_to :post
  # belongs_to :recipient_group, class_name: :Group, foreign_key: :recipient_group_id
  # 이미 fk는 recipeint_group_id임.
  belongs_to :recipient_group, class_name: :Group
end
