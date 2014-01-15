require 'perpetuity'
require 'perpetuity/exceptions/duplicate_key_error'
require 'perpetuity/attribute'
require 'set'
require 'securerandom'

module Perpetuity
  class Memory
    def initialize options = {}
      @cache    = Hash.new
      @indexes  = Hash.new
    end

    def insert klass, object, _
      if object.is_a? Array
        return object.map{|obj| insert(klass, obj, _)}
      end

      id = get_id(object) || set_id(object, SecureRandom.uuid)

      collection(klass)[id] = object
      id
    end

    def count klass, criteria=nil, &block
      if block_given?
        collection(klass).values.select(&block).size
      elsif criteria
        collection(klass).values.select(&criteria).size
      else
        collection(klass).size
      end
    end

    def delete_all klass
      collection(klass).clear
    end

    def first klass
      all(klass).first
    end

    def find klass, id
      collection(klass)[id]
    end

    def retrieve klass, criteria, options = {}
      collection(klass).values.find_all(&criteria)
    end

    def all klass
      collection(klass).values
    end

    def delete object, klass=nil
      klass ||= object.class
      id = object.class == String || !object.respond_to?(:id) ? object : object.id

      collection(klass).each_with_index do |record, index|
        if record[:id] === id
          collection(klass).delete_at index
        end
      end
    end

    def update klass, id, new_data
      collection(klass).each_with_index do |record, index|
        if record[:id] == id
          collection(klass)[index] = record.merge(new_data)
        end
      end
    end

    def increment klass, id, attribute, count=1
      find(klass, id)[attribute] += count
    end

    def can_serialize? value
      true
    end

    def serialize object, mapper
      object.dup
    end

    def unserialize data, mapper
      data.dup
    end


    def index klass, attribute, options={}
      indexes(klass) << attribute
    end

    def indexes klass
      @indexes[klass] ||= Set.new
    end

    def active_indexes klass
      indexes(klass)
    end

    def activate_index! klass
      true
    end

    def remove_index index
    end

    def query &block
      block
    end

    def drop_collection klass
      @cache[klass] = Hash.new
    end

    protected

    def collection klass
      @cache[klass] = Hash.new unless @cache.has_key? klass
      @cache[klass]
    end

    def get_id(object)
      if object.respond_to?(:id)
        object.id
      elsif object.respond_to?(:fetch)
        object.fetch(:id, nil)
      elsif object.respond_to?(:[])
        object[:id] || nil
      else
        object.instance_variable_get(:@id)
      end
    end

    def set_id(object, id)
      if object.respond_to?(:id=)
        object.id = id
      elsif object.respond_to?(:[]=)
        object[:id] = id
      else
        object.instance_variable_set(:@id, id)
      end
      id
    end
  end
end


# Register the adapter with Perpetuity.
Perpetuity::Configuration.adapters[:memory] = 'Perpetuity::Memory'
