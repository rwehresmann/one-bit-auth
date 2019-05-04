class User < ApplicationRecord
  validates_presence_of :auth0_uid, :email
end
