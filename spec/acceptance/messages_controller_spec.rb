require 'rails_helper'

RSpec.resource 'Messages' do
  explanation 'Messages resource'
  header 'Content-Type', 'application/json'

  get '/api/v1/messages' do
    example 'Listing messages for all users' do
      message_one, message_two, message_three = create_list(:message, 3)

      do_request

      expect(status).to eq 200
      expect(response_json).to match(
                                 messages: [
                                   a_hash_including(id: message_three.id,
                                                    content: message_three.content,
                                                    sender: a_hash_including(
                                                      id: message_three.sender.id,
                                                      username: message_three.sender.username,
                                                      email: message_three.sender.email
                                                    ),
                                                    recipient: a_hash_including(
                                                      id: message_three.recipient.id,
                                                      username: message_three.recipient.username,
                                                      email: message_three.recipient.email
                                                    ),
                                                    sent_at: message_three.sent_at.as_json,
                                                    read_at: message_three.read_at.as_json),
                                   a_hash_including(id: message_two.id),
                                   a_hash_including(id: message_one.id)
                                 ]
                               )

    end

    example 'Limits messages to 100', document: false do
      messages = create_list(:message, 101)

      do_request

      expect(status).to eq 200
      expect(response_json[:messages].size).to eq 100
      expect(response_json[:messages]).not_to include(a_hash_including(id: messages.first.id))
    end

    example 'Limits messages to those created in the last 30 days', document: false do
      Timecop.freeze do
        message = create(:message, sent_at: 30.days.ago)
        create(:message, sent_at: 30.days.ago - 1.second)

        do_request

        expect(status).to eq 200
        expect(response_json[:messages].size).to eq 1
        expect(response_json[:messages].first).to match a_hash_including(id: message.id)
      end
    end

    context 'when requesting messages for a specific sender' do
      parameter :filters, type: :hash, items: { sender_id: :string }
      let(:sender) { create(:user) }

      example 'Listing messages for a specific sender' do
        other_sender = create(:user)

        create_list(:message, 3, sender: sender)
        create(:message, sender: other_sender)

        do_request(filters: { sender_id: sender.id })

        expect(status).to eq 200
        expect(response_json[:messages].size).to eq 3
      end
    end

    context 'when requesting messages for a specific recipient' do
      parameter :filters, type: :hash, items: { recipient_id: :string }
      let(:recipient) { create(:user) }

      example 'Listing messages for a specific recipient' do
        other_recipient = create(:user)

        create_list(:message, 3, recipient: recipient)
        create(:message, recipient: other_recipient)

        do_request(filters: { recipient_id: recipient.id })

        expect(status).to eq 200
        expect(response_json[:messages].size).to eq 3
      end
    end

    context 'when requesting messages for a specific conversation' do
      parameter :filters, type: :hash, items: { sender_id: :string, recipient_id: :string }
      let(:recipient) { create(:user) }
      let(:sender) { create(:user) }

      example 'Listing messages for a specific conversation' do
        other_sender = create(:user)

        create_list(:message, 3, recipient: recipient, sender: sender)
        create(:message, sender: sender)
        create(:message, recipient: recipient)
        create(:message, sender: other_sender)

        do_request(filters: { recipient_id: recipient.id, sender_id: sender.id })

        expect(status).to eq 200
        expect(response_json[:messages].size).to eq 3
      end

      example 'Limits messages to 100', document: false do
        messages = create_list(:message, 101, recipient: recipient, sender: sender)

        do_request(filters: { recipient_id: recipient.id, sender_id: sender.id })

        expect(status).to eq 200
        expect(response_json[:messages].size).to eq 100
        expect(response_json[:messages]).not_to include a_hash_including(id: messages.first.id)
      end

      example 'Limits messages to the last 30 days', document: false do
        Timecop.freeze do
          message = create(:message, recipient: recipient, sender: sender, sent_at: 30.days.ago)
          create(:message, recipient: recipient, sender: sender, sent_at: 30.days.ago - 1.second)

          do_request(filters: { recipient_id: recipient.id, sender_id: sender.id })

          expect(status).to eq 200
          expect(response_json[:messages].size).to eq 1
          expect(response_json[:messages].first).to match a_hash_including(id: message.id)
        end
      end
    end
  end
end
