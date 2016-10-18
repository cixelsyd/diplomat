require 'base64'
require 'faraday'

module Diplomat
  class Kv < Diplomat::RestClient

    attr_reader :key, :value, :raw, :key_exist

    # Check to see if a key exists
    # @param key [String] the key
    # @return [Boolean] exists - true or false
    def key_exist key
      @key = key
      @raw = @conn.get "/v1/kv/#{@key}"
      if @raw.status == 200
        return true
      else
        return false
      end
    end

    # Get a value by it's key
    # @param key [String] the key
    # @return [String] The base64-decoded value associated with the key
    def get key
      @key = key
      @raw = @conn.get "/v1/kv/#{@key}"
      parse_body
      return_value
    end

    # Put a value by it's key
    # @param key [String] the key
    # @param value [String] the value
    # @return [String] The base64-decoded value associated with the key
    def put key, value
      @raw = @conn.put do |req|
        req.url "/v1/kv/#{key}"
        req.body = value
      end
      if @raw.body == "true\n"
        @key   = key
        @value = value
      end
      return @value
    end

    # Delete a value by it's key
    # @param key [String] the key
    # @return [nil]
    def delete key
      @key = key
      @raw = @conn.delete "/v1/kv/#{@key}"
      return_key
      return_value
    end

    # @note This is sugar, see (#key_exists?)
    def self.key_exist *args
      Diplomat::Kv.new.key_exist *args
    end

    # @note This is sugar, see (#get)
    def self.get *args
      Diplomat::Kv.new.get *args
    end

    # @note This is sugar, see (#put)
    def self.put *args
      Diplomat::Kv.new.put *args
    end

    # @note This is sugar, see (#delete)
    def self.delete *args
      Diplomat::Kv.new.delete *args
    end

    private

    # Parse the body, apply it to the raw attribute
    def parse_body
      @raw = JSON.parse(@raw.body).first
    end

    # Get the key from the raw output
    def return_key
      @key = @raw["Key"]
    end

    # Get the value from the raw output
    def return_value
      @value = @raw["Value"]
      @value = Base64.decode64(@value) unless @value.nil?
    end

  end
end
