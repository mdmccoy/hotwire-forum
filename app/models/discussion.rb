# frozen_string_literal: true

class Discussion < ApplicationRecord
  belongs_to :user, default: -> { Current.user }
  belongs_to :category, counter_cache: true, touch: true
  has_many :posts, dependent: :destroy
  has_many :users, through: :posts

  scope :pinned_first, -> { order(pinned: :desc).order(updated_at: :desc) }

  validates :name, presence: true

  accepts_nested_attributes_for :posts

  delegate :name, prefix: :category, to: :category, allow_nil: true

  broadcasts_to :category # , inserts_by: :prepend # this is the default behavior

  after_create_commit { broadcast_prepend_to('discussions') }
  after_update_commit do
    broadcast_replace_to('discussions')
  end
  after_destroy_commit { broadcast_remove_to('discussions') }

  def to_param
    "#{id}-#{name.downcase.to_s[0...20]}".parameterize
  end
end
