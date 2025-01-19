# frozen_string_literal: true

class DiscussionSubscription < ApplicationRecord
  belongs_to :discussion
  belongs_to :user

  enum subscription_type: { optin: 0, optout: 1 }

  validates :subscription_type, presence: true
  validates :user_id, uniqueness: { scope: :discussion_id }

  def toggle!
    case subscription_type
    when 'optin'
      update(subscription_type: 'optout')
    when 'optout'
      update(subscription_type: 'optin')
    end
  end
end
