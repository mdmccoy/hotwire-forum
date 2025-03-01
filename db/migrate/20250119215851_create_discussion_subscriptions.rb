# frozen_string_literal: true

class CreateDiscussionSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :discussion_subscriptions do |t|
      t.references :discussion, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :subscription_type

      t.timestamps
    end
  end
end
