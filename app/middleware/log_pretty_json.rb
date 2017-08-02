# From http://panupan.com/2013/01/22/how-to-log-formatted-json-responses-in-your-rails-application/
class LogPrettyJson
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)

    if defined?(Rails) && headers["Content-Type"] =~ /^application\/json/
      obj = JSON.parse(response.body)
      pretty_str = JSON.pretty_unparse(obj)
      Rails.logger.debug("Response: " + pretty_str)
    end

    [status, headers, response]
  end
end
