module Auth0
  class Signin
    def self.perform(email, password)
      ctx = OpenSSL::SSL::SSLContext.new
      ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE

      HTTP.headers(accept: 'application/json')
          .post(
            "https://#{ENV['AUTH0_DOMAIN']}/oauth/token",
            ssl_context: ctx,
            json: {
              grant_type: 'password',
              username: email,
              password: password,
              scope: 'openid',
              audience: ENV['AUTH0_AUDIENCE'],
              client_id: ENV['AUTH0_CLIENT_ID'],
              client_secret: ENV['AUTH0_CLIENT_SECRET'],
            }
          )
    end
  end
end
