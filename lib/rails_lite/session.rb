require 'json'
require 'webrick'

class Session
  def initialize(req)
    cookies = req.cookies
    @session_hash = {}
    cookies.each do |cookie|
      if cookie.name == "_rails_lite_app"
        @session_hash = JSON.parse(cookie.value)
      end
    end
  end

  def [](key)
    @session_hash[key]
  end

  def []=(key, val)
    @session_hash[key] = val
  end

  def store_session(res)
    res.cookies << WEBrick::Cookie.new("_rails_lite_app", @session_hash.to_json)
  end
end
