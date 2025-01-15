# frozen_string_literal: true

class PostsController < ApplicationController
  def new
    @post = Post.new
  end
end
