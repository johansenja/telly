class User < ApplicationRecord
  has_many :posts, foreign_key: :user_identifier, primary_key: :identifier
  belongs_to :organisation
  has_one :family, class_name: "Fam"
end
