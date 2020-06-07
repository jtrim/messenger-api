class Api::V1::MessagesController < ApplicationController
  def index
    scope = Message
    scope = scope.sent_by_id(sender_id_filter) if filtering_by_sender?
    scope = scope.sent_to_id(recipient_id_filter) if filtering_by_recipient?

    messages = scope.most_recent_first
                 .before_date_cutoff
                 .limit(100)

    serializer = Api::V1::MessageSerializer.new(messages)

    render json: serializer
  end

  def create
    ok, message = MessageService::Create.call(message_create_attributes)

    if ok
      serializer = Api::V1::MessageSerializer.new(message)
      render json: serializer, status: :created
    else
      serializer = Api::V1::UnprocessableEntitySerializer.new(message)
      render json: serializer, status: :unprocessable_entity
    end
  end

  def update
    message = Message.find(params[:id])

    if message.update(message_update_attributes)
      serializer = Api::V1::MessageSerializer.new(message)
      render json: serializer, status: :ok
    else
      serializer = Api::V1::UnprocessableEntitySerializer.new(message)
      render json: serializer, status: :unprocessable_entity
    end
  end

  private

  def message_create_attributes
    params.require(:attributes).permit(:content, :recipient_id, :sender_id, :sent_at, :sender_username, :recipient_username)
  end

  def message_update_attributes
    params.require(:attributes).permit(:read_at)
  end

  def sender_id_filter
    filters[:sender_id]
  end

  def recipient_id_filter
    filters[:recipient_id]
  end

  def filters
    params[:filters] || {}
  end

  def filtering_by_sender?
    sender_id_filter.present?
  end

  def filtering_by_recipient?
    recipient_id_filter.present?
  end
end
