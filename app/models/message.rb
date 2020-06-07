class Message < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'

  scope :most_recent_first, -> { order('sent_at desc') }
  scope :before_date_cutoff, ->(days: 30) { where('sent_at >= ?', Time.now - days.days) }
  scope :sent_by_id, ->(user_id) { where(sender_id: user_id) }
  scope :sent_to_id, ->(user_id) { where(recipient_id: user_id) }
end
