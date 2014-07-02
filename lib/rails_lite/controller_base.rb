require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'


class ControllerBase
  attr_reader :params, :req, :res

  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = Params.new(req, route_params)
  end

  def render_content(content, type)

    raise "Response has already been built" if already_built_response?
    res.content_type = type
    res.body = content
    session.store_session(@res)
    @already_built_response = true
  end

  def already_built_response?
    @already_built_response
  end

  def redirect_to(url)
    raise "Response has already been built" if already_built_response?
    res["Location"] = url
    res.status = 302
    session.store_session(@res)
    @already_built_response = true
  end

  def render(template_name)
    controller_name = self.class.to_s.underscore
    template = File.read("views/#{controller_name}/#{template_name}.html.erb")
    erb_template = ERB.new(template)
    content = erb_template.result(binding)
    render_content(content, "text/html")
  end

  def session
    @session ||= Session.new(@req)
  end

 def invoke_action(name)
    self.send(name)
  end
end
