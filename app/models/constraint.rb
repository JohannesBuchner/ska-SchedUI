class Constraint < ActiveRecord::Base
  belongs_to :job

  has_many :source
end
