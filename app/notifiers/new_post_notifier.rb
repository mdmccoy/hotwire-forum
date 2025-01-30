# frozen_string_literal: true

# To deliver this notification:
#
# NewPostNotifier.with(record: @post, message: "New post").deliver(User.all)

class NewPostNotifier < ApplicationNotifier
  # Add your delivery methods
  #
  # deliver_by :email do |config|
  #   config.mailer = "UserMailer"
  #   config.method = "new_post"
  # end
  #
  # bulk_deliver_by :slack do |config|
  #   config.url = -> { Rails.application.credentials.slack_webhook_url }
  # end
  #
  # deliver_by :custom do |config|
  #   config.class = "MyDeliveryMethod"
  # end

  # Add required params
  #
  # required_param :message
  # required_param :record
  #

  def post
    record
  end

  def message
    "New post in #{post.discussion.name}"
  end

  def url
    discussion_path(post.discussion)
  end
end
