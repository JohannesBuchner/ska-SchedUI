class Job < ActiveRecord::Base
  belongs_to :proposal
  has_many :constraint
end
