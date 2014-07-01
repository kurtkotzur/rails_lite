class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  def matches?(req)
    req.request_method.downcase.to_sym == @http_method &&
    req.path =~ pattern 
    
  end

  # use pattern to pull out route params (save for later?)
  # instantiate controller and call controller action
  def run(req, res)
    m = pattern.match(req.path)
  
    params = {}
    m.names.each do |name|
      params[name] = m[name]
    end
    controller = @controller_class.new(req, res, params)
    controller.invoke_action(@action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  # evaluate the proc in the context of the instance
  # for syntactic sugar :)
  def draw(&proc)
    self.instance_eval(&proc)
  end

  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  def match(req)
    @routes.select { |route| route.matches?(req) }.first
  end

  def run(req, res)
    unless match(req)
      res.status = 404
      return
    end
    match(req).run(req, res)
  end
end
