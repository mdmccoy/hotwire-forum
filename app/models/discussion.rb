# frozen_string_literal: true

class Discussion < ApplicationRecord
  belongs_to :user, default: -> { Current.user }
  belongs_to :category, counter_cache: true, touch: true
  has_many :posts, dependent: :destroy
  has_many :users, through: :posts
  has_many :discussion_subscriptions, dependent: :destroy
  has_many :optin_subscribers, -> { where(discussion_subscriptions: { subscription_type: 'optin' }) },
           through: :discussion_subscriptions,
           source: :user
  has_many :optout_subscribers, -> { where(discussion_subscriptions: { subscription_type: 'optout' }) },
           through: :discussion_subscriptions,
           source: :user

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

  def subscribed_users
    (users + optin_subscribers).uniq - optout_subscribers
  end

  def subscription_for(user)
    return nil if user.nil?

    discussion_subscriptions.find_by(user_id: user.id)
  end

  def toggle_subscription(user)
    return nil if user.nil?

    if (sub = subscription_for(user))
      sub.toggle!
    elsif posts.where(user_id: user.id).any?
      discussion_subscriptions.create(user:, subscription_type: 'optout')
    else
      discussion_subscriptions.create(user:, subscription_type: 'optin')
    end
  end

  def subscribed?(user)
    return false if user.nil?

    if (subscription = subscription_for(user))
      subscription.subscription_type == 'optin'
    else
      posts.where(user_id: user.id).any?
    end
  end

  def subscribed_reason(user)
    return "You're not getting notifications from this thread" if user.nil?

    if (subscription = subscription_for(user))
      if subscription.subscription_type == 'optout'
        "You've opted out of this discussion"
      elsif subscription.subscription_type == 'optin'
        "You're subscribed to this discussion"
      end
    elsif posts.where(user_id: user.id).any?
      "You've posted in this discussion"
    else
      "You're not getting notifications from this thread"
    end
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
