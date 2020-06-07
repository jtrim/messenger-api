class Api::V1::MessagesController < ApplicationController
  def index
    scope = Message.all

    if user_ids = between_user_ids_filter
      return unless assert_pair user_ids, :between_user_ids
      scope = scope.between_user_ids(user_ids)
    elsif usernames = between_usernames_filter
      return unless assert_pair usernames, :between_usernames
      scope = scope.between_usernames(usernames)
    else
      scope = scope.sent_by_id(sender_id_filter) if filtering_by_sender?
      scope = scope.sent_to_id(recipient_id_filter) if filtering_by_recipient?
    end

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

  def assert_pair(vals, key)
    return true if vals.size == 2

    serializer = Api::V1::UnprocessableEntitySerializer.with_errors(key => "must contain exactly two values")
    render json: serializer, status: :unprocessable_entity

    false
  end

  def between_user_ids_filter
    filters[:between_user_ids]
  end

  def between_usernames_filter
    filters[:between_usernames]
  end

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
