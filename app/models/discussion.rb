# frozen_string_literal: true

class Discussion < ApplicationRecord
  include TurboStreamConcern

  belongs_to :user, default: -> { Current.user }
  belongs_to :category, counter_cache: true, touch: true
  has_many :posts, dependent: :destroy
  has_many :users, through: :posts

  scope :pinned_first, -> { order(pinned: :desc).order(updated_at: :desc) }

  validates :name, presence: true

  accepts_nested_attributes_for :posts

  delegate :name, prefix: :category, to: :category, allow_nil: true

  def to_param
    "#{id}-#{name.downcase.to_s[0...20]}".parameterize
  end
end
