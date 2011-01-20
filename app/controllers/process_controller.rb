class ProcessController < ApplicationController
  def index
    jp = Java::LocalRadioscheduler::Proposal
    jj = Java::LocalRadioscheduler::Job 

    p = Proposal.first
    j = Job.find(p.id)
  end
end
