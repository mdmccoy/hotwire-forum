# frozen_string_literal: true

module Discussions
  class PostsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_discussion
    before_action :set_post, only: %i[show edit update destroy]

    def show; end

    def edit; end

    def create
      @post = @discussion.posts.new(post_params)

      respond_to do |format|
        if @post.save
          if params.dig('post', 'redirect').present?
            @pagy, @posts = pagy(@discussion.posts.order(created_at: :desc))
            format.html do
              redirect_to discussion_path(@discussion, page: @pagy.last), notice: 'Post Created!'
            end
          else
            @post = @discussion.posts.new
            format.turbo_stream
          end
        else
          format.turbo_stream
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    def update
      respond_to do |format|
        if @post.update(post_params)
          format.html { redirect_to @post.discussion, notice: 'Post Updated!' }
        else
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @post.destroy

      respond_to do |format|
        format.turbo_stream {} # rubocop:disable Lint/EmptyBlock
        format.html { redirect_to @post.discussion, notice: 'Post was successfully destroyed.' }
      end
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
