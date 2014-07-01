require 'uri'

class Params
  def initialize(req, route_params = {})
    @params = route_params
    parse_www_encoded_form(req.query_string)
    parse_www_encoded_form(req.body)
  end

  def [](key)
    @params[key]
  end

  def permit(*keys)
    if instance_variable_defined?("@permitted_keys")
      @permitted_keys.concat(keys)
    else
      @permitted_keys = keys
    end
  end

  def require(key)
    raise AttributeNotFoundError unless self[key]
  end

  def permitted?(key)
    @permitted_keys.include?(key)
  end

  def to_s
    @params.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private

  def parse_www_encoded_form(www_encoded_form)
    return if www_encoded_form.nil?
    query_array = URI::decode_www_form(www_encoded_form)
    query_array.each do |pair|
      parsed_keys = parse_key(pair.first)
      current_key = parsed_keys.shift
      current_hash_level = @params
      while parsed_keys.count >= 0
        if parsed_keys.count > 0
          current_hash_level[current_key] = {}
        else
          current_hash_level[current_key] = pair.last
          break
        end
        current_hash_level = current_hash_level[current_key]
        current_key = parsed_keys.shift
      end
    end
  end

  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end
end
