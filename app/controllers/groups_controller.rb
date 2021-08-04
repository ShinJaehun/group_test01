class GroupsController < ApplicationController
  #before_action :set_group, only: %i[ show edit update destroy ]
  before_action :set_group, except: %i[ index new create ]
  before_action :authenticate_user!
  #load_and_authorize_resource except: %i[ index new create apply_group join_group leave_group ]
  load_and_authorize_resource except: %i[ index new create apply_group cancel_apply leave_group ]
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

    # @pending_users = User.includes(:user_groups).where("user_groups.state": "pending")
    # 이렇게 하면 사용자가 다른 그룹에서 pending하고 있어도 pending_users에 포함됨
    @pending_users = User.find(@group.user_groups.where(state: "pending").pluck(:user_id))
    @active_users = User.find(@group.user_groups.where(state: "active").pluck(:user_id))
    #이렇게 구현할 수 있지만 다양한 방법을 알아두는 게 필요함!
    #결국 내가 맞았다!
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)

    if Group.find_by(name: @group.name).present?
      flash.now[:danger] = "That group name has already been taken."

      render 'new'
    else
      @group.save
      # usergroup 먼저 save 불가. 아마도 group.id 때문이 아닐까?

      usergroup = UserGroup.new
      usergroup.user_id = current_user.id
      usergroup.group_id = @group.id
      usergroup.state = "active"
      usergroup.save
      # 근데 이렇게 하면 group은 save에 성공하고 usergroup save에 실패했을 때 오류처리를 어떻게 하나
      # group과 usergroup save를 한 트랜젝션에서 처리하고 싶은데...

      current_user.add_role :group_manager, @group
      current_user.add_role :group_member, @group
      # 생성한 그룹에 대해 group_manager role 부여

      redirect_to @group, notice: "Group was successfully created."
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
    if current_user.has_role? :group_manager, @group
      if User.find(@group.user_groups.where(state: "active").pluck(:user_id)).count == 1 and @group.user_groups.where(state: "active").pluck(:user_id).first == current_user.id
      # group_member가 단 한명이고 그게 나라면 그룹 삭제 가능
      # 그룹 멤버가 있는 상태에서 삭제 못하는 정책?

        @posts = Post.find(@group.post_recipient_groups.pluck(:post_id))
        unless @posts.blank?
          @posts.each do |p|
            p.destroy
          end
        end
        # post_recipient_groups와 user_groups 모두 삭제되는데 post_recipient_group에 연결된 posts는 그대로 남아 있음...
        # 그래서 이렇게 group에 속한 post를 모두 삭제한 다음에 group을 삭제할 수 있음
        # 언젠가 혹시 모를 일에 대비하기 위해 post는 삭제하지 말고 놔둬야 하는가?

        # current_user.remove_role :group_member, @group
        # current_user.remove_role :group_manager, @group
        # 그룹 권한 삭제 : 굳이 할 필요 없음 rolify에서 dependent: destroy로 처리하는 거 같음.

        @group.destroy
        redirect_to groups_url, notice: "Group was successfully destroyed."
      else
        redirect_to groups_url, notice: "group_manager를 제외하고 group_member가 존재하면 그룹 삭제 불가 "
      end
    else
      redirect_to groups_url, notice: "group_manager가 아님"
    end
  end

  def join_group
    # approve 없이 그룹에 join
    # 정책에 따라서 이렇게 허가 없이 join만 해도 바로 승인되는 경우를 허용해야 함...
    if UserGroup.where(user_id: current_user.id, group_id: @group.id).count <= 0
      usergroup = UserGroup.new
      usergroup.user_id = current_user.id
      usergroup.group_id = @group.id
      usergroup.state = 'active'
      usergroup.save

      current_user.add_role :group_member, @group
      redirect_to @group, notice: "You've been added to #{@group.name}."
    else
      redirect_to groups_path, notice: "You're already a member of #{@group.name}."
    end
  end

  def apply_group
    if UserGroup.where(user_id: current_user.id, group_id: @group.id).count <= 0
      usergroup = UserGroup.new
      usergroup.user_id = current_user.id
      usergroup.group_id = @group.id
      usergroup.state = 'pending'
      usergroup.save
      redirect_to @group, notice: "You've been applied for #{@group.name}."
    else
      redirect_to groups_path, notice: "You're already a member of #{@group.name}."
    end
  end

  def cancel_apply
    apply_user = User.find(params[:apply_user_id])

    usergroup = apply_user.user_groups.find_by_group_id(@group.id)
    if usergroup.state == 'pending' && usergroup.user_id == apply_user.id && usergroup.group_id == @group.id
      usergroup.destroy
      redirect_to groups_path, notice: "Applying has been canceled."
    else
      redirect_to @group, notice: "user/group 오류 또는 active 상태가 아님"
    end
  end

  def approve_user
    apply_user = User.find(params[:apply_user_id])

    if current_user.has_role? :group_manager, @group
      #usergroup = UserGroup.where(user_id: params[:apply_user_id], group_id: @group.id)
      #이건 안 되는디(user_groups)
      usergroup = apply_user.user_groups.find_by_group_id(@group.id)
      #이건 된다...왜????(user_group)

      if usergroup.state == 'pending' && usergroup.user_id == apply_user.id && usergroup.group_id == @group.id
        usergroup.state = 'active'
        usergroup.save
        apply_user.add_role :group_member, @group
        # 멤버 승인하면서 group_member role 부여
        redirect_to @group, notice: "#{apply_user.name}'s been approved."
      else
        redirect_to groups_path, notice: "user/group 오류 또는 pending 상태가 아님"
      end
    else
      redirect_to groups_path, notice: "group_manager가 아님"
    end
  end

  def suspend_user
    suspend_user = User.find(params[:suspend_user_id])

    if current_user.has_role? :group_manager, @group
      usergroup = suspend_user.user_groups.find_by_group_id(@group.id)

      if usergroup.state == 'active' && usergroup.user_id == suspend_user.id && usergroup.group_id == @group.id
        usergroup.state = 'pending'
        usergroup.save
        suspend_user.remove_role :group_member, @group
        redirect_to @group, notice: "#{suspend_user.name}'s been suspended."
      else
        redirect_to groups_path, notice: "user/group 오류 또는 pending 상태가 아님"
      end
    else
      redirect_to groups_path, notice: "group_manager가 아님"
    end
  end

  def leave_group
    if !current_user.has_role? :group_manager, @group
      if current_user.has_role? :group_member, @group
        current_user.remove_role :group_member, @group
        usergroup = current_user.user_groups.find_by_group_id(@group.id)
        if usergroup.state == 'active' && usergroup.user_id == current_user.id && usergroup.group_id == @group.id
          usergroup.destroy
          redirect_to groups_path, notice: "You're no longer a member of #{@group.name}."
        else
          redirect_to @group, notice: "user/group 오류 또는 active 상태가 아님"
        end
      else
        redirect_to @group, notice: "group_member가 아님"
      end
    else
      redirect_to @group, notice: "group_manager는 탈퇴 불가"
    end
  end

  private

  def set_group
    @group = Group.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:name)
  end
end
