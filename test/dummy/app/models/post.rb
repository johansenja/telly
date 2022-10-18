class Post < ApplicationRecord
  belongs_to :user, foreign_key: :user_identifier, primary_key: :identifier
end
