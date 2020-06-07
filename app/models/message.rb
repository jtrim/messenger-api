class Message < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'

  scope :most_recent_first, -> { order('sent_at desc') }
  scope :before_date_cutoff, ->(days: 30) { where('sent_at >= ?', Time.now - days.days) }
  scope :sent_by_id, ->(user_id) { where(sender_id: user_id) }
  scope :sent_to_id, ->(user_id) { where(recipient_id: user_id) }
  scope :between_usernames, ->(usernames) do
    joins(:sender, :recipient).where(
      users: { username: usernames.first },
      recipients_messages: { username: usernames.last }
    ).or(
      joins(:sender, :recipient).where(
        users: { username: usernames.last},
        recipients_messages: { username: usernames.first}
      )
    )
  end
  scope :between_user_ids, ->(user_ids) do
    where(sender_id: user_ids.first, recipient_id: user_ids.last)
      .or(where(sender_id: user_ids.last, recipient_id: user_ids.first))
  end

  validates :sent_at, :sender, :recipient, :content, presence: :true
end
