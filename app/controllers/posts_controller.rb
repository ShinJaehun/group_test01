class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]
  before_action :authenticate_user!
  load_and_authorize_resource

  # GET /posts or /posts.json
  def index
    #@posts = Post.all
    @posts = Post.find(current_user.post_recipients.pluck(:post_id))
    @post = Post.new
  end

  # GET /posts/1 or /posts/1.json
  def show
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts or /posts.json
  def create
    @post = current_user.posts.new(post_params)

    if params[:type] == 'group'
#    puts '###################################'
#    puts params[:receiver_id]
#    puts Group.find(params[:receiver_id])
#    puts current_user.has_role? :group_member, Group.find(params[:receiver_id])
#    puts '###################################'
      if current_user.has_role? :group_member, Group.find(params[:receiver_id])
        @post.save
        post_recipient_group = PostRecipientGroup.new
        post_recipient_group.recipient_group_id = params[:receiver_id]
        post_recipient_group.post_id = @post.id
        post_recipient_group.save!
        redirect_back(fallback_location: root_path, flash: {notice: "그룹에 글을 작성했습니다!"})
      else
        redirect_back(fallback_location: root_path, flash: {notice: "그룹에 글을 남길 권한 없음!"})
      end
    elsif params[:type] == 'user'
      @post.save
      post_recipient = PostRecipient.new
      post_recipient.recipient_id = params[:receiver_id]
      post_recipient.post_id = @post.id
      post_recipient.save!
      redirect_back(fallback_location: root_path, flash: {notice: "글을 작성했습니다!"})
    else
      redirect_to root_path, flash: {notice: "뭐시여 이건 그룹 포스트도 아니여 유저 포스트도 아니여..."}
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: "Post was successfully updated." }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: "Post was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      puts params.inspect
      params.require(:post).permit(:content)
      # hidden_field_tag는 permit 없이도 받을 수 있음.
      #params.permit(:content)
      # 여기 이렇게 해봤던 건 뭔가 실수 해서 post를 빼먹었던 건데 지금 다시 생각이 안남
    end
end
