class Api::V1::MessageSerializer < Api::V1::BaseSerializer
  resource_name :message
  attributes :content, :sender, :recipient, :sent_at, :read_at

  def sender(resource)
    serialize_model resource.sender, Api::V1::UserSerializer if resource.sender.present?
  end

  def recipient(resource)
    serialize_model resource.recipient, Api::V1::UserSerializer if resource.sender.present?
  end
end
