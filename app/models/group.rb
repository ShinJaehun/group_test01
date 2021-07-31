class Group < ApplicationRecord
  has_many :user_groups
  has_many :users, through: :user_groups

  has_many :post_recipient_groups, foreign_key: :recipient_group_id
  # 아 씨발 이게 졸라 중요했던거야 post_recipient_groups 테이블에서
  # group_id 대신 recipient_group_id를 사용하려면 말이지...
  # 그리고 이게 있어야 has_many 관계가 정상적으로 동작함

  validates :name, presence: true, uniqueness: true

  # after_save :join_user_group_by_creating

  private

  def join_user_group_by_creating
    # @usergroup = UserGroup.create!(user_id: self.user_id, group_id: self.id)
    # 이게 안되는 이유는 group에 user_id가 없어서 이기 때문...(사실 굳이 있을 필요는 없지)
  end

end
