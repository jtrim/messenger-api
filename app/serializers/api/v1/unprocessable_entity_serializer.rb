class Api::V1::UnprocessableEntitySerializer < Api::V1::BaseSerializer
  def as_json(*args)
    {
      errors: {
        messages: resource.errors.full_messages,
        attributes: resource.errors.to_h
      }
    }.as_json(*args)
  end
end
