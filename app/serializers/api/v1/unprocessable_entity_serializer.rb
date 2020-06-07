class Api::V1::UnprocessableEntitySerializer < Api::V1::BaseSerializer
  def self.with_errors(errors)
    error_collector = MessageCollector.new
    errors.each { |key, msgs| Array(msgs).each { |m| error_collector.add(key, m) } }
    new(OpenStruct.new(errors: error_collector))
  end

  def as_json(*args)
    {
      errors: {
        messages: resource.errors.full_messages,
        attributes: resource.errors.to_h
      }
    }.as_json(*args)
  end
end
