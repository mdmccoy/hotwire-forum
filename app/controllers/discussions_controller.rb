class DiscussionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @discussions = Discussion.all
  end

  def new
    @discussion = Discussion.new
  end

  def create
    @discussion = Discussion.new(discussion_params)
    @discussion.user = current_user

    respond_to do |format|
      if @discussion.save
        format.html { redirect_to discussions_path, notice: 'Discussion was successfully created.' }
      else
        flash[:alert] = 'Discussion could not be created.'
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  private

  def discussion_params
    params.require(:discussion).permit(:name, :pinned, :closed)
  end
end
