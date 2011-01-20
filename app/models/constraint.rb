class Constraint < ActiveRecord::Base
  belongs_to :job
  has_many :sources
end
