module Stix2
  class Common < Hashie::Dash
    include Hashie::Extensions::Dash::PredefinedValues
    include Hashie::Extensions::IndifferentAccess
    include Hashie::Extensions::Dash::Coercion

    property :type, required: true, coerce: String
    property :spec_version, coerce: String, values: ['2.1']
    property :id, coerce: Identifier
    property :created_by_ref, coerce: Identifier
    property :created, coerce: Time
    property :modified, coerce: Time
    property :revoked, coerce: Stix2::Boolean
    property :labels, coerce: Array[String]
    property :confidence, coerce: Integer
    property :lang, coerce: String
    property :external_references, coerce: Array[ExternalReference]
    property :object_marking_refs, coerce: Array[Stix2::MetaObject::DataMarking::ObjectMarking]
    property :granular_markings, coerce: Array[MetaObject::DataMarking::GranularMarking]
    property :defanged, coerce: Stix2::Boolean
    property :extensions, coerce: Hash

    def initialize(options = {})
      Hashie.symbolize_keys!(options)
      type = to_dash(self.class.name.split('::').last)
      if options[:type]
        raise("Property 'type' must be '#{type}'") if options[:type] != type
      else
        options[:type] = type
      end
      super(options)
      Stix2.storage_add(self)
    end

    def method_missing(m, *args, &block)
      if !m.to_s.end_with?('_instance')
        super(m, args, block)
        return
      end
      # Retrieve the original method
      ref_method = m.to_s.gsub(/_instance$/, '')
      obj = send(ref_method)
      raise("Can't get a Stix2::Identifier from #{ref_method}") if !obj.is_a?(Stix2::Identifier)
      Stix2.storage_find(obj)
    end

    private

    def to_dash(string)
      string.gsub(/[[:upper:]]/) { "-#{$&.downcase}" }[1..]
    end

    def self.validate_array(list, valid_values)
      excess = (Array(list) - valid_values)
      excess.empty? || raise("Invalid values: #{excess}")
      list
    end

    def self.hash_dict(hsh)
      invalids = hsh.keys.map(&:to_s) - HASH_ALGORITHM_OV
      invalids.empty? || raise("Invalid values: #{invalids}")
      hsh
    end
  end
end
