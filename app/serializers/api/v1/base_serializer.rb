class Api::V1::BaseSerializer
  def self.resource_name(val = nil)
    @resource_name = val if val.present?
    @resource_name
  end

  def self.attributes(*attrs)
    @attributes = attrs.map(&:to_s)

    _attributes.each do |attr|
      define_method(attr) do |resource|
        resource.public_send(attr)
      end
    end
  end

  def self._attributes
    ['id'] + Array(@attributes)
  end

  def initialize(resource_or_resources, **options)
    @resource = resource_or_resources
    @options = options.with_indifferent_access
  end

  def as_json(*args)
    attrs = if options.key?(:include)
              self.class._attributes & (Array(options[:include]))
            else
              self.class._attributes
            end

    if options[:as_include]
      attributes_hash = resource_to_attrs_hash(resource, attrs)
      attributes_hash.as_json(*args)
    else
      resources = Array(resource)
      attributes_hashes = resources.map { |r| resource_to_attrs_hash(r, attrs) }

      { resource_name => attributes_hashes }.as_json(*args)
    end
  end

  private

  attr_reader :resource, :options

  def serialize_model(model, serializer, as_include: true)
    serializer.new(model, as_include: as_include)
  end

  def resource_name
    (self.class.resource_name ||
     self.class.name.demodulize.underscore.sub(/_serializer/, '')).pluralize
  end

  def resource_to_attrs_hash(resource, attrs)
    pairs = attrs.map do |attr|
      [
        attr.to_s,
        public_send(attr, resource)
      ]
    end
    Hash[pairs]
  end
end
