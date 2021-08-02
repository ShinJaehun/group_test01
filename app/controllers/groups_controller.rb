class GroupsController < ApplicationController
  #before_action :set_group, only: %i[ show edit update destroy ]
  before_action :set_group, except: %i[ index new create ]
  before_action :authenticate_user!
  load_and_authorize_resource except: %i[ index new create join_group leave_group ]
  # 이렇게 해야 그룹에 속하지 않은 user가 새로 group을 생성할 수 있음.
  # 가입/탈퇴도 포함되어야 함...

  def index
    @groups = Group.all
    #@groups = current_user.groups
    #원래 자기가 속한 그룹만 보여주는게 맞는데 권한 테스트하느라 모든 그룹을 보여주고 있음.
  end

  def show
    puts '#########################################'
    puts @group.post_recipient_groups.pluck(:post_id)
    puts '#########################################'
    # 이렇게 하면 post_id를 배열로 추출할 수 있음!

    @posts = Post.find(@group.post_recipient_groups.pluck(:post_id))
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)

    # @group = current_user.groups.new(group_params)
    # @group[:user_id] = current_user.id
    # group에 user_id 항목이 없으니 굳이 이렇게 생성할 필요 없음.

    if Group.find_by(name: @group.name).present?
      flash.now[:danger] = "That group name has already been taken."
      render 'new'
    else

      @group.save
      # usergroup 먼저 save 불가. 아마도 group.id 때문이 아닐까?

      @usergroup = UserGroup.new
      @usergroup.user_id = current_user.id
      @usergroup.group_id = @group.id
      @usergroup.save

      respond_to do |format|
        format.html { redirect_to @group, notice: "Group was successfully created." }
      end
    end
  end

  def update
    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to @group, notice: "Group was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @posts = Post.find(@group.post_recipient_groups.pluck(:post_id))
    unless @posts.blank?
      @posts.each do |p|
        p.destroy
      end
    end
    # post_recipient_groups와 user_groups 모두 삭제되는데 post_recipient_group에 연결된 posts는 그대로 남아 있음...
    # 그래서 이렇게 group에 속한 post를 모두 삭제한 다음에 group을 삭제할 수 있음
    # 언젠가 혹시 모를 일에 대비하기 위해 post는 삭제하지 말고 놔둬야 하는가?

    @group.destroy
    respond_to do |format|
      format.html { redirect_to groups_url, notice: "Group was successfully destroyed." }
    end
  end

  def join_group
    if UserGroup.where(user_id: current_user.id, group_id: @group.id).count <= 0
      @usergroup = UserGroup.new
      @usergroup.user_id = current_user.id
      @usergroup.group_id = @group.id
      @usergroup.save
      redirect_to @group, notice: "You've been added to #{@group.name}."
    else
      redirect_to groups_path, notice: "You're already a member of #{@group.name}."
    end
  end

  def leave_group
    usergroup = current_user.user_groups.find_by_group_id(@group.id)
    usergroup.destroy
    current_user.save!
    redirect_to groups_path, notice: "You're no longer a member of #{@group.name}."
  end

  private

  def set_group
    @group = Group.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:name)
  end
end
