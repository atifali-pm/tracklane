class Mention < ApplicationRecord
  belongs_to :comment
  belongs_to :user
  belongs_to :organization
end
