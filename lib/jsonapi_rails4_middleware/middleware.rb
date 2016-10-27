module JsonapiRails4Middleware
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)

      if request.content_type == 'application/json'
        request.body.rewind
        body = request.body.read
        request.body.rewind
        json_params = body.empty? ? {} : JSON.parse(body)
        data = json_params.fetch('data', nil)
        attributes = data['attributes']
        type = data['type']
        jsonapi =  data && attributes && type

        if jsonapi
          resource_name = type.singularize
          params = {}
          params[resource_name] = attributes
          id = data['id']
          params[resource_name]['id'] = id if id
          env['rack.input'] = StringIO.new(params.to_json)
        end
      end

      @app.call(env)
    end
  end
end
