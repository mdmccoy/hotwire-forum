# frozen_string_literal: true

class Category < ApplicationRecord
  include TurboStreamConcern

  has_many :discussions, dependent: :nullify

  scope :sorted, -> { order(name: :asc) }
end
