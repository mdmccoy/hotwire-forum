# frozen_string_literal: true

class Discussion < ApplicationRecord
  belongs_to :user, default: -> { Current.user }
  has_many :posts, dependent: :destroy
  has_many :users, through: :posts

  validates :name, presence: true

  accepts_nested_attributes_for :posts

  after_create_commit { broadcast_prepend_to 'discussions' }
  after_update_commit { broadcast_replace_to 'discussions' }
  after_destroy_commit { broadcast_remove_to 'discussions' }

  def to_param
    "#{id}-#{name.downcase.to_s[0...20]}".parameterize
  end
end
