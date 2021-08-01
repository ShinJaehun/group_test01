class User < ApplicationRecord
  rolify
  #뭔 조화인지 user 삭제하려는데 또 FK constraint가 발생해서 rolify를 적용하지 않으면
  #정상 동작하더라고... 그래서 이거 해결하려고 여러 생쑈를 벌였는데(rolify user destroy FK constraint)
  #어느 순간부터 그냥 되더라고...
  #그럼 그렇지 그렇게 사용자가 많은 gem이 그렇게 허투루 만들어졌겠어
  #ㅠㅠ 웹 서버 재시작

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true
  has_many :posts, dependent: :destroy

  has_many :user_groups, dependent: :destroy
  has_many :groups, through: :user_groups

  has_many :post_recipients, foreign_key: :recipient_id, dependent: :destroy

end
