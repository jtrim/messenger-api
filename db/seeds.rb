puts "Seeding users"

jesse = User.create!(username: 'jesse', email: 'jesse@jesse.net')
someone = User.create!(username: 'someone', email: 'someone@jesse.net')

puts "Seeding messages"

Message.create!(sender: jesse, recipient: someone, content: "Hey @someone, what's up?", sent_at: Time.now)
Message.create!(sender: someone, recipient: jesse, content: "Yo @jesse, not much. How about you?", sent_at: Time.now)
