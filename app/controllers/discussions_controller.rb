# frozen_string_literal: true

class DiscussionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_discussion, only: %i[edit update destroy show]
  rescue_from ActiveRecord::RecordNotFound, with: -> { redirect_to discussions_path, notice: 'Discussion not found' }

  def index
    flash.keep if turbo_frame_request?
    @pagy, @discussions = pagy(Discussion.pinned_first.includes([:category]))
  end

  def show
    @pagy, @posts = pagy(@discussion.posts.includes(%i[user rich_text_body]).order(created_at: :asc), limit: 5)
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
