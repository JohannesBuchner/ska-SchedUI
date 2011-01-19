class Job < ActiveRecord::Base
  belongs_to :constraint
  belongs_to :proposal
  has_many :source
  has_many :bad_date
end
