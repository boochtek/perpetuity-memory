require 'perpetuity'
require 'perpetuity/exceptions/duplicate_key_error'
require 'perpetuity/attribute'
require 'set'
require 'securerandom'

module Perpetuity
  class Memory
    def initialize options = {}
      @cache    = Hash.new
      @indexes  = Hash.new { |hash, key| hash[key] = active_indexes(key) }
    end

    def insert klass, attributes, _
      if attributes.is_a? Array
        return attributes.map{|attr| insert(klass, attr, _)}
      end

      unless attributes.has_key? :id
        attributes[:id] = SecureRandom.uuid
      end

      # make keys indifferent
      attributes.default_proc = proc do |h, k|
        case k
          when String then sym = k.to_sym; h[sym] if h.key?(sym)
          when Symbol then str = k.to_s; h[str] if h.key?(str)
        end
      end

      collection(klass) << attributes
      attributes[:id]
    end

    def count klass, criteria=nil, &block
      if block_given?
        collection(klass).select(&block).size
      elsif criteria
        collection(klass).select(&criteria).size
      else
        collection(klass).size
      end
    end

    def delete_all klass
      collection(klass).clear
    end

    def first klass
      collection(klass).first
    end

    def find klass, id
      collection(klass).find{|o| o[:id] = id}
    end

    def retrieve klass, criteria, options = {}
      collection(klass).find_all(&criteria)
    end

    def all klass
      collection(klass)
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
      Marshal.dump(object)
    end

    def unserialize data, mapper
      Marshal.load(data)
    end


    def index klass, attribute, options={}
      @indexes[klass] ||= Set.new
    end

    def indexes klass
      @indexes[klass]
    end

    def active_indexes klass
      Set.new
    end

    def activate_index! klass
      true
    end

    def remove_index index
    end

    def query &block
      block
    end

    protected

    def collection klass
      @cache[klass] = Array.new unless @cache.key? klass
      @cache[klass]
    end
  end
end
