module RequestSupport
  def response_json
    JSON[response_body].with_indifferent_access
  end
end
