
require 'java'
import 'java.util.HashSet'

# TODO, check return on queries for nil results
# for error handling

class ProcessController < ApplicationController
  def index
    # first, gather all proposals
    all_proposals = Proposal.all
    proposal_set = HashSet.new
    
    # loop over proposals building java data structures
    # gather local reference to Java Proposal type
    # and Java Job type
    j_proposal = Java::LocalRadioschedulers::Proposal
    j_job  = Java::LocalRadioschedulers::Job 
    all_proposals.each do |p|

      # set up individual proposal
      jp = j_proposal.new
      jp.id = p.id.to_s
      jp.name = p.name
      jp.start = Java::JavaUtil::Date.new
      jp.priority = p.priority

      # now find all jobs related to this proposal
      # TODO: Check return!
      all_jobs_by_proposal_t = Job.find_by_proposal_id(p.id)
      # If one row is returned, it's just that type so, force it to array
      if ( all_jobs_by_proposal_t.class == Job )
        all_jobs_by_proposal = Array.new([all_jobs_by_proposal_t])
      else
        all_jobs_by_proposal = all_jobs_by_proposal_t
      end

      job_set = HashSet.new
      all_jobs_by_proposal.each do |j|
        jj = j_job.new
        jj.proposal = jp

        # Constraints contain info about the job
        # TODO: will there ever be multiple constraints per job?
        # based on this usage, there should never be..
        # TODO: Check return!

        jj.hours = j.totalhours

        jj.lstmin = j.startlst
        jj.lstmax = j.endlst

        job_set.add(jj)
      end # all_jobs_by_proposal.each
      jp.jobs = job_set
      
      proposal_set.add(jp)
    end # all_proposals.each

    # Okay, whew, that's a bit crazy up there, now lets get a move on!
    schedule_factory = Java::LocalRadioschedulersApi::SchedulePipeline.new
    guard = Java::LocalRadioschedulersPreschedule::SingleRequirementGuard.new
    
    schedule_space = schedule_factory.getScheduleSpace( proposal_set, guard, 90 )
    puts "got a schedule space", schedule_space.to_string
    
  end
end
