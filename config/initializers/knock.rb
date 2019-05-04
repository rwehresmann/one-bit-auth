Knock.setup do |config|
  if Rails.env.test?
    config.token_secret_signature_key = -> { Rails.application.credentials.read }
  else
    config.token_audience = -> { ENV['AUTH0_AUDIENCE'] }

    # auth0 uses RS256.
    config.token_signature_algorithm = 'RS256'

    # API secret from Auth0.
    config.token_secret_signature_key = -> { ENV['AUTH0_CLIENT_SECRET'] }

    # RS256 is an asymmetric algorithm, which means it requires a private and public key.
    jwks_raw = HTTP.get(ENV['AUTH0_RSA_DOMAIN']).body.to_s
    jwks_keys = Array(JSON.parse(jwks_raw)['keys'])
    config.token_public_key = OpenSSL::X509::Certificate.new(Base64.decode64(jwks_keys[0]['x5c'].first)).public_key
  end
end

# Find our User by id in test environment, and auth0_uid in other environments.
Knock::AuthToken.class_eval do
  def entity_for(entity_class)
    key_to_find = Rails.env.test? ? :id : :auth0_uid
    entity_class.find_by(key_to_find => @payload['sub'])
  end
end


# Uncomment this method if you're receiving odds 401 errors.
# What I changed here is to raise an error through this method
# if Knock::AuthToken raises an error. Here, silent errors make
# hard to undertand the problem origin (like the use of a wrong algorithm
# for token signature, for instance).
# Knock::Authenticable.module_eval do
#   def define_current_entity_getter(entity_class, getter_name)
#     unless self.respond_to?(getter_name)
#       memoization_var_name = "@_#{getter_name}"
#       self.class.send(:define_method, getter_name) do
#         unless instance_variable_defined?(memoization_var_name)
#           current = Knock::AuthToken.new(token: token).entity_for(entity_class)

#           instance_variable_set(memoization_var_name, current)
#         end
#         instance_variable_get(memoization_var_name)
#       end
#     end
#   end
# end
