module Discussions
  class PostsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_discussion

    def create
      @post = @discussion.posts.new(post_params)

      respond_to do |format|
        if @post.save
          format.html { redirect_to @discussion }
        else
          format.turbo_stream { render turbo_stream: turbo_stream.replace(@post, partial: "posts/form", locals: { post: @post }) }
          format.html { render :new, status: :unprocessable_entity}
        end
      end
    end

    def destroy
      @post = @discussion.posts.find(params[:id])
      @post.destroy
      redirect_to @discussion
    end

    private

    def set_discussion
      @discussion = Discussion.find(params[:discussion_id])
    end

    def post_params
      params.require(:post).permit(:body)
    end
  end
end
