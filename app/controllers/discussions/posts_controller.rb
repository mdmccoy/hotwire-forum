# frozen_string_literal: true

module Discussions
  class PostsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_discussion
    before_action :set_post, only: %i[show edit update]

    def show; end

    def edit; end

    def create
      @post = @discussion.posts.new(post_params)

      respond_to do |format|
        if @post.save
          format.html { redirect_to @discussion, notice: 'Post Created!' }
        else
          format.turbo_stream do
            # This response can also be defined in <controller method name>.turbo_stream.erb
            # render turbo_stream: turbo_stream.replace(@post, partial: 'discussions/posts/form', locals: { post: @post })
          end
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    def update
      respond_to do |format|
        if @post.update(post_params)
          format.html { redirect_to @post.discussion, notice: 'Post Updated!' }
        else
          # @post.broadcast_replace(partial: 'discussions/posts/post', locals: { post: @post })
          # format.turbo_stream do
          #   # This response can also be defined in <controller method name>.turbo_stream.erb
          #   # render turbo_stream: turbo_stream.replace(@post, partial: 'discussions/posts/form', locals: { post: @post })
          # end
          format.html { render :edit, status: :unprocessable_entity }
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

    def set_post
      @post = @discussion.posts.find(params[:id])
    end

    def post_params
      params.require(:post).permit(:body)
    end
  end
end
