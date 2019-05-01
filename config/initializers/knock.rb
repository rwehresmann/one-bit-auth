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
