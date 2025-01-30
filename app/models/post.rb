# frozen_string_literal: true

class Post < ApplicationRecord
  belongs_to :discussion, counter_cache: true, touch: true
  belongs_to :user, default: -> { Current.user }
  has_rich_text :body
  has_many :noticed_events, as: :record, dependent: :destroy, class_name: 'Noticed::Event'
  validates :body, presence: true

  after_create_commit do
    broadcast_append_to discussion, partial: 'discussions/posts/post', locals: { post: self }
    NewPostNotifier.with(record: self).deliver(discussion.subscribed_users)
  end
  after_update_commit  { broadcast_replace_to discussion, partial: 'discussions/posts/post', locals: { post: self } }
  after_destroy_commit { broadcast_remove_to discussion }
end
