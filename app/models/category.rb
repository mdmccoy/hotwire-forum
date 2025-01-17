# frozen_string_literal: true

class Category < ApplicationRecord
  include TurboStreamConcern

  has_many :discussions, dependent: :nullify

  scope :sorted, -> { order(name: :asc) }

  def to_param
    "#{id}-#{name.downcase.to_s[0..100]}".parameterize
  end
end
