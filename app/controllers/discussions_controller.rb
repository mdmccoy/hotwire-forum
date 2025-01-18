# frozen_string_literal: true

class DiscussionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_discussion, only: %i[edit update destroy show]
  rescue_from ActiveRecord::RecordNotFound, with: -> { redirect_to discussions_path, notice: 'Discussion not found' }

  def index
    flash.keep if turbo_frame_request?
    @discussions = Discussion.pinned_first.includes([:category])
  end

  def show
    # TODO: Change this to @new_post so it's less confusing
    @posts = @discussion.posts.includes(%i[user rich_text_body]).order(created_at: :asc)
    @post = @discussion.posts.new
  end

  def new
    @discussion = Discussion.new
    @discussion.posts.new
  end

  def edit; end

  def create
    @discussion = Discussion.new(discussion_params)
    @discussion.user = current_user

    respond_to do |format|
      if @discussion.save
        format.html { redirect_to @discussion, notice: 'Discussion was successfully created.' }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @discussion.update(discussion_params)
        @discussion.broadcast_replace(partial: 'discussions/header', discussion: @discussion)

        if @discussion.saved_change_to_category_id?
          old_category_id, new_category_id = @discussion.saved_change_to_category_id

          old_category = Category.find(old_category_id)
          new_category = Category.find(new_category_id)

          @discussion.broadcast_remove_to(old_category)
          @discussion.broadcast_prepend_to(new_category)

          old_category.reload.broadcast_replace_to('categories')
          new_category.reload.broadcast_replace_to('categories')
        end

        if @discussion.saved_change_to_closed?
          @discussion.broadcast_action_to(@discussion, action: :replace,
                                                       target: 'new_post_form',
                                                       partial: 'discussions/posts/form',
                                                       locals: { post: @discussion.posts.new })
        end

        format.html { redirect_to @discussion, notice: 'Discussion was successfully updated.' }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @discussion.destroy!
    respond_to do |format|
      format.html { redirect_to discussions_path, notice: 'Discussion was successfully destroyed.' }
      format.turbo_stream { render turbo_stream: turbo_stream.action(:redirect, discussions_path) }
    end
  end

  private

  def discussion_params
    params.require(:discussion).permit(:name, :pinned, :closed, :category_id, posts_attributes: %i[body])
  end

  def set_discussion
    @discussion = Discussion.find(params[:id])
  end
end
