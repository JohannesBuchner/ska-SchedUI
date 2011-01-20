class Job < ActiveRecord::Base
  belongs_to :proposal

  has_many :constraints, :dependent => :destroy
  has_many :bad_dates, :dependent => :destroy

end
