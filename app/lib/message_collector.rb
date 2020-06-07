class MessageCollector
  def initialize
    @messages = Hash.new { |h, k| h[k] = [] }
  end

  def add(key, message)
    messages[key] << message
  end

  def full_messages
    messages.flat_map do |key, messages|
      Array(messages).map { |message| "#{key.to_s.humanize} #{message}" }
    end
  end

  def to_h
    messages
  end

  private

  attr_reader :messages
end
