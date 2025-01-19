# frozen_string_literal: true

class Discussion < ApplicationRecord
  belongs_to :user, default: -> { Current.user }
  belongs_to :category, counter_cache: true, touch: true
  has_many :posts, dependent: :destroy
  has_many :users, through: :posts

  scope :pinned_first, -> { order(pinned: :desc, updated_at: :desc) }

  validates :name, presence: true

  accepts_nested_attributes_for :posts

  delegate :name, prefix: :category, to: :category, allow_nil: true

  broadcasts_to :category # , inserts_by: :prepend # this is the default behavior

  after_create_commit { broadcast_prepend_to('discussions') }
  after_update_commit do
    broadcast_replace_to('discussions')
    replace_headers
    move_categories if saved_change_to_category_id?
    update_new_post_form if saved_change_to_closed?
  end
  after_destroy_commit { broadcast_remove_to('discussions') }

  def to_param
    "#{id}-#{name.downcase.to_s[0...20]}".parameterize
  end

  private

  def replace_headers
    broadcast_replace(partial: 'discussions/header', discussion: self)
  end

  def move_categories
    old_category_id, new_category_id = saved_change_to_category_id

    old_category = Category.find(old_category_id)
    new_category = Category.find(new_category_id)

    broadcast_remove_to(old_category)
    broadcast_prepend_to(new_category)

    old_category.reload.broadcast_replace_to('categories')
    new_category.reload.broadcast_replace_to('categories')
  end

  def update_new_post_form
    broadcast_action_to(
      self,
      action: :replace,
      target: 'new_post_form',
      partial: 'discussions/posts/form',
      locals: { post: posts.new }
    )
  end
end
