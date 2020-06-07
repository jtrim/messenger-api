module MessageService
  class Create
    def self.call(attributes)
      ActiveRecord::Base.transaction do
        message_attributes = attributes.except(:sender_username, :recipient_username)
        message = Message.new(message_attributes)

        sender_username, recipient_username = attributes.values_at(:sender_username, :recipient_username)

        if sender_username
          sender = User.find_or_create_by!(username: sender_username)
          message.sender = sender
        end

        if recipient_username
          recipient = User.find_or_create_by!(username: recipient_username)
          message.recipient = recipient
        end

        if message.save
          [true, message]
        else
          [false, message]
        end
      end
    end
  end
end
