class Api::V1::MessagesController < ApplicationController
  def index
    scope = Message
    scope = scope.sent_by_id(sender_id) if filtering_by_sender?
    scope = scope.sent_to_id(recipient_id) if filtering_by_recipient?

    messages = scope.most_recent_first
                 .before_date_cutoff
                 .limit(100)

    serializer = Api::V1::MessageSerializer.new(messages)

    render json: serializer
  end

  private

  def sender_id
    filters[:sender_id]
  end

  def recipient_id
    filters[:recipient_id]
  end

  def filters
    params[:filters] || {}
  end

  def filtering_by_sender?
    sender_id.present?
  end

  def filtering_by_recipient?
    recipient_id.present?
  end
end
