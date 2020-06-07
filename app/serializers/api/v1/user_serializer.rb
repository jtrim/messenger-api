class Api::V1::UserSerializer < Api::V1::BaseSerializer
  resource_name :user
  attributes :username, :email
end
