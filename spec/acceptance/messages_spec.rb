# coding: utf-8
require 'rails_helper'

RSpec.resource 'Messages' do
  explanation <<-MARKDOWN
  The **Messages** resource is the primary endpoint for this application. It provides for listing messages, creating new
  messages, and updating existing messages.
  MARKDOWN

  header 'Content-Type', 'application/json'

  get '/api/v1/messages' do
    example 'Listing messages for all users' do
      explanation <<-MARKDOWN
      The number of messages this endpoint will produce is limited to 100, and the API does not currently support pagination.

      Only messages created within the last 30 days will be returned.
      MARKDOWN

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
                                                      email: message_three.sender.email),
                                                    recipient: a_hash_including(
                                                      id: message_three.recipient.id,
                                                      username: message_three.recipient.username,
                                                      email: message_three.recipient.email),
                                                    sent_at: message_three.sent_at.as_json,
                                                    read_at: message_three.read_at.as_json),
                                   a_hash_including(id: message_two.id),
                                   a_hash_including(id: message_one.id)
                                 ]
                               )

    end

    example '↳ Limits messages to 100', document: false do
      messages = create_list(:message, 101)

      do_request

      expect(status).to eq 200
      expect(response_json[:messages].size).to eq 100
      expect(response_json[:messages]).not_to include(a_hash_including(id: messages.first.id))
    end

    example '↳ Limits messages to those created in the last 30 days', document: false do
      Timecop.freeze do
        message = create(:message, sent_at: 30.days.ago)
        create(:message, sent_at: 30.days.ago - 1.second)

        do_request

        expect(status).to eq 200
        expect(response_json[:messages].size).to eq 1
        expect(response_json[:messages].first).to match a_hash_including(id: message.id)
      end
    end

    context 'When requesting messages for a specific sender' do
      parameter :filters, type: :hash, items: { sender_id: :string }
      let(:sender) { create(:user) }

      example 'Listing messages for a specific sender' do
        explanation <<-MARKDOWN
        The **Messages** API can be used to list messages sent by a specific user to any other user.
        MARKDOWN

        other_sender = create(:user)

        create_list(:message, 3, sender: sender)
        create(:message, sender: other_sender)

        do_request(filters: { sender_id: sender.id })

        expect(status).to eq 200
        expect(response_json[:messages].size).to eq 3
      end
    end

    context 'When requesting messages for a specific recipient' do
      parameter :filters, type: :hash, items: { recipient_id: :string }
      let(:recipient) { create(:user) }

      example 'Listing messages for a specific recipient' do
        explanation <<-MARKDOWN
        The **Messages** API can also be used to list messages sent received by a specific user from any other user.
        MARKDOWN
        other_recipient = create(:user)

        create_list(:message, 3, recipient: recipient)
        create(:message, recipient: other_recipient)

        do_request(filters: { recipient_id: recipient.id })

        expect(status).to eq 200
        expect(response_json[:messages].size).to eq 3
      end
    end

    context 'When requesting messages between a sender and a recipient' do
      parameter :filters, type: :hash, items: { sender_id: :string, recipient_id: :string }
      let(:recipient) { create(:user) }
      let(:sender) { create(:user) }

      example 'Listing messages between an sender and a recipient' do
        explanation <<-MARKDOWN
        The **Messages** API can be used to list messages between a sender and a recipient.
        MARKDOWN
        other_sender = create(:user)

        create_list(:message, 3, recipient: recipient, sender: sender)
        create(:message, sender: sender)
        create(:message, recipient: recipient)
        create(:message, sender: other_sender)

        do_request(filters: { recipient_id: recipient.id, sender_id: sender.id })

        expect(status).to eq 200
        expect(response_json[:messages].size).to eq 3
      end

      example '↳ Limits messages to 100', document: false do
        messages = create_list(:message, 101, recipient: recipient, sender: sender)

        do_request(filters: { recipient_id: recipient.id, sender_id: sender.id })

        expect(status).to eq 200
        expect(response_json[:messages].size).to eq 100
        expect(response_json[:messages]).not_to include a_hash_including(id: messages.first.id)
      end

      example '↳ Limits messages to the last 30 days', document: false do
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

    context 'When requesting messages for a conversation between two users by username' do
      parameter('filters[between_usernames]', 'Two usernames', { type: :array })
      let(:user1) { create(:user) }
      let(:user2) { create(:user) }

      example 'Listing messages for a specific conversation between users by username' do
        explanation <<-MARKDOWN
        The **Messages** API can be used to list messages between two usernames.
        MARKDOWN
        other_sender = create(:user)

        create_list(:message, 3, recipient: user1, sender: user2)
        create_list(:message, 3, recipient: user2, sender: user1)
        create(:message, sender: user1)
        create(:message, recipient: user2)
        create(:message, sender: other_sender)

        do_request(filters: { between_usernames: [user1.username, user2.username] })

        expect(status).to eq 200
        expect(response_json[:messages].size).to eq 6
      end

      example '↳ When the number of supplied usernames is not exactly two' do
        do_request(filters: { between_usernames: ['foo', 'bar', 'baz'] })
        expect(status).to eq 422
        expect(response_json).to match(
                                   a_hash_including(
                                     errors: a_hash_including(
                                       attributes: {
                                         between_usernames: ['must contain exactly two values']
                                       }
                                     )
                                   )
                                 )
      end
    end

    context 'When requesting messages for a conversation between two users by user ids' do
      parameter('filters[between_user_ids]', 'Two user ids', { type: :array })
      let(:user1) { create(:user) }
      let(:user2) { create(:user) }

      example 'Listing messages for a specific conversation between users by user ids' do
        explanation <<-MARKDOWN
        The **Messages** API can be used to list messages between two users when given two user ids.
        MARKDOWN
        other_sender = create(:user)

        create_list(:message, 3, recipient: user1, sender: user2)
        create_list(:message, 3, recipient: user2, sender: user1)
        create(:message, sender: user1)
        create(:message, recipient: user2)
        create(:message, sender: other_sender)

        do_request(filters: { between_user_ids: [user1.id, user2.id] })

        expect(status).to eq 200
        expect(response_json[:messages].size).to eq 6
      end

      example '↳ When the number of supplied user ids is not exactly two' do
        do_request(filters: { between_user_ids: [1, 2, 3] })
        expect(status).to eq 422
        expect(response_json).to match(
                                   a_hash_including(
                                     errors: a_hash_including(
                                       attributes: {
                                         between_user_ids: ['must contain exactly two values']
                                       }
                                     )
                                   )
                                 )
      end
    end
  end

  post '/api/v1/messages' do
    let(:sender) { create(:user) }
    let(:recipient) { create(:user) }

    let(:raw_post) do
      {
        attributes: {
          sender_id: sender.id,
          recipient_id: recipient.id,
          content: 'An example message between two friends',
          sent_at: Time.now
        }
      }.to_json
    end

    context 'When the user ids are known' do
      parameter :attributes, type: :hash, items: { sender_id: :string, recipient_id: :string, content: :string, sent_at: :datetime }

      example 'Creating a message in a conversation between two users' do
        explanation <<-MARKDOWN
        When creating messages, it's important to note that the client is responsible for supplying the `sent_at` value.
        MARKDOWN

        expect { do_request }.to change { Message.count }.by(1)

        message = Message.last

        expect(status).to eq 201
        expect(response_json[:messages]).to match [
                                              a_hash_including(id: message.id,
                                                               content: message.content,
                                                               sender: a_hash_including(
                                                                 id: message.sender.id,
                                                                 username: message.sender.username,
                                                                 email: message.sender.email),
                                                               recipient: a_hash_including(
                                                                 id: message.recipient.id,
                                                                 username: message.recipient.username,
                                                                 email: message.recipient.email),
                                                               sent_at: message.sent_at.as_json,
                                                               read_at: message.read_at.as_json)]

      end
    end

    context 'When the user ids are not known' do
      parameter :attributes, type: :hash, items: { sender_username: :string, recipient_username: :string, content: :string, sent_at: :datetime }

      let(:raw_post) do
        {
          attributes: {
            sender_username: 'by-tor',
            recipient_username: 'the_snow_dog',
            content: 'An example message between two friends',
            sent_at: Time.now
          }
        }.to_json
      end

      example 'Creating a message between two usernames' do
        explanation <<-MARKDOWN
        In cases where the user IDs are not known (such as initiating a chat), the system will automatically create a
        user by a given username if it doesn't already exist. If a user *does* already exist by the given username, the
        existing user record will be used.
        MARKDOWN
        expect(User.find_by(username: 'by-tor')).to be nil
        expect(User.find_by(username: 'the_snow_dog')).to be nil

        expect { do_request }.to change { Message.count }.by(1)

        message = Message.last

        by_tor = User.find_by(username: 'by-tor')
        the_snow_dog = User.find_by(username: 'the_snow_dog')

        expect(status).to eq 201
        expect(response_json[:messages]).to match [
                                              a_hash_including(id: message.id,
                                                               content: message.content,
                                                               sender: a_hash_including(
                                                                 id: by_tor.id,
                                                                 username: by_tor.username,
                                                                 email: nil),
                                                               recipient: a_hash_including(
                                                                 id: the_snow_dog.id,
                                                                 username: the_snow_dog.username,
                                                                 email: nil),
                                                               sent_at: message.sent_at.as_json,
                                                               read_at: message.read_at.as_json)]
      end

      context 'When users already exist by the given usernames' do
        specify '↳ It finds existing users', document: false do
          by_tor = create(:user, username: 'by-tor')
          the_snow_dog = create(:user, username: 'the_snow_dog')

          expect do
            expect { do_request }.to change { Message.count }.by(1)
          end.not_to change { User.count }

          message = Message.last

          expect(status).to eq 201
          expect(response_json[:messages]).to match [
                                                a_hash_including(id: message.id,
                                                                 content: message.content,
                                                                 sender: a_hash_including(
                                                                   id: by_tor.id,
                                                                   username: by_tor.username,
                                                                   email: by_tor.email),
                                                                 recipient: a_hash_including(
                                                                   id: the_snow_dog.id,
                                                                   username: the_snow_dog.username,
                                                                   email: the_snow_dog.email),
                                                                 sent_at: message.sent_at.as_json,
                                                                 read_at: message.read_at.as_json)]
        end
      end
    end

    context 'With invalid attributes' do
      let(:raw_post) do
        # No content or sent_at
        {
          attributes: {
            sender_id: sender.id,
            recipient_id: recipient.id
          }
        }.to_json
      end

      example 'Attempting to create a message with invalid attributes' do
        explanation <<-MARKDOWN
        The API will respond with error messages and an appropraite status code in the event that there is a problem with the incoming data.
        MARKDOWN

        expect { do_request }.not_to change { Message.count }

        expect(status).to eq 422
        expect(response_json).to match a_hash_including(
                                         errors: {
                                           messages: ["Sent at can't be blank", "Content can't be blank"],
                                           attributes: {
                                             sent_at: "can't be blank",
                                             content: "can't be blank"
                                           }
                                         })
      end
    end
  end

  put '/api/v1/messages/:id' do
    let(:id) { message.id }
    let(:message) { create(:message) }

    context 'When marking a message as read' do
      parameter :attributes, type: :hash, items: { read_at: :datetime }
      let(:read_at) { Time.now.change(usec: 0) }

      let(:raw_post) do
        {
          attributes: {
            read_at: read_at
          }
        }.to_json
      end

      example "Updating a message's \"read\" status" do
        explanation <<-MARKDOWN
        A message can be updated with a `read_at` value to indicate the recipient of the message has seen it.
        MARKDOWN

        expect { do_request }.to change { message.reload.read_at }.from(nil).to(read_at)

        expect(status).to eq 200
        expect(response_json[:messages]).to match [
                                              a_hash_including(id: message.id,
                                                               content: message.content,
                                                               sender: a_hash_including(
                                                                 id: message.sender.id,
                                                                 username: message.sender.username,
                                                                 email: message.sender.email),
                                                               recipient: a_hash_including(
                                                                 id: message.recipient.id,
                                                                 username: message.recipient.username,
                                                                 email: message.recipient.email),
                                                               sent_at: message.sent_at.as_json,
                                                               read_at: message.read_at.as_json)]
      end
    end
  end
end
