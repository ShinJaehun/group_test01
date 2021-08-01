class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]
  before_action :authenticate_user!
  load_and_authorize_resource

  # GET /posts or /posts.json
  def index
    #@posts = Post.all
    @posts = Post.find(current_user.post_recipients.pluck(:post_id))
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
    #@post = Post.new(post_params)
    @post = current_user.posts.new(post_params)

    puts '###################################'
#    puts post_params
#    puts params[:group_id]
    puts params[:type]
    puts params[:receiver_id]
    puts post_params[:post]
    puts '###################################'

    @post.save

      # 사용자에게 글 남기기 테스트
#        post_recipient = PostRecipient.new
#        post_recipient.recipient_id = current_user.id
#        post_recipient.post_id = @post.id
#        post_recipient.save!

      # 그룹에 글 남기기 테스트
#        current_user.groups.each do |g|
#          post_recipient_group = PostRecipientGroup.new
#          post_recipient_group.recipient_group_id = g.id
#          post_recipient_group.post_id = @post.id
#          post_recipient_group.save!
#        end
    if params[:type] == 'group'
      post_recipient_group = PostRecipientGroup.new
      post_recipient_group.recipient_group_id = params[:receiver_id]
      # 아 븅시나 post_params[:group_id]로 하면 이걸 받을 수가 있겠냐고!
      # hidden_field_tag로 넘기는 값은 permit할 필요가 없는거구나...
      post_recipient_group.post_id = @post.id
      post_recipient_group.save!
    else params[:type] == 'user'
      post_recipient = PostRecipient.new
      post_recipient.recipient_id = params[:receiver_id]
      post_recipient.post_id = @post.id
      post_recipient.save!
    end

    redirect_back(fallback_location: root_path)

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
