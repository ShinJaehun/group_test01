class Group < ApplicationRecord
  has_many :user_groups
  has_many :users, through: :user_groups


  validates :name, presence: true, uniqueness: true

  # after_save :join_user_group_by_creating

  private

  def join_user_group_by_creating
    # @usergroup = UserGroup.create!(user_id: self.user_id, group_id: self.id)
    # 이게 안되는 이유는 group에 user_id가 없어서 이기 때문...(사실 굳이 있을 필요는 없지)
  end

end
