# frozen_string_literal: true

class Discussion < ApplicationRecord
  belongs_to :user, default: -> { Current.user }

  validates :name, presence: true

  after_create_commit { broadcast_prepend_to "discussions" }
  after_update_commit { broadcast_replace_to "discussions" }
  after_destroy_commit { broadcast_remove_to "discussions" }

  def to_param
    "#{id}-#{name.downcase.to_s[0...20]}".parameterize
  end
end
