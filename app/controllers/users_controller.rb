class UsersController < ApplicationController
  before_action :set_user

  def show
    puts '#########################################'
    puts @user.post_recipients.pluck(:post_id)
    puts '#########################################'

    @posts = Post.find(@user.post_recipients.pluck(:post_id))

  end


  private

  def set_user
    @user = User.find(params[:id])
  end
end
