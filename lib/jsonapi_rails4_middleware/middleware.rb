module JsonapiRails4Middleware
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      if env['CONTENT_TYPE'] == 'application/json'
        env['rack.input'].rewind
        body = env['rack.input'].read
        env['rack.input'].rewind

        (body.empty? ? {} : JSON.parse(body)).tap do |json_params|
          break unless data = json_params['data']

          attributes = data['attributes']
          type = data['type']
          break unless attributes && type

          if id = data['id']
            attributes['id'] = id
          end

          resource_name = type.singularize

          env['rack.input'] = StringIO.new({ resource_name => attributes }.to_json)
        end
      end

      @app.call(env)
    end
  end
end
