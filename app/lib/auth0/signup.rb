module Auth0
  class Signup
    def self.perform(email, password)
      HTTP.headers(accept: 'application/json')
          .post(
            "https://#{ENV['AUTH0_DOMAIN']}/dbconnections/signup",
            form: {
              client_id: ENV['AUTH0_CLIENT_ID'],
              email: email,
              password: password,
              connection: 'Username-Password-Authentication',
            }
          )
    end
  end
end