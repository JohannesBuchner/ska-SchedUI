
require 'java'
import 'java.util.HashSet'
import 'java.util.ArrayList'

FitnessFunc = Java::LocalRadioschedulersGaFitness::SimpleScheduleFitnessFunction
LST_SLOTS_MINUTES = Java::LocalRadioschedulers::Schedule::LST_SLOTS_MINUTES
class MyFitnessFunction < FitnessFunc
  alias :super_evaluateSlotJob :evaluateSlotJob
  
  # @param job Job
  # @param timeleft long, minutes
  # @param inPreviousSlot boolean
  def evaluateSlotJob(j, timeleft, inPreviousSlot)
    #super_evaluateSlotJob(j, timeleft, inPreviousSlot)
    if (inPreviousSlot)
       time = LST_SLOTS_MINUTES
    else
       time = LST_SLOTS_MINUTES - getSwitchLostMinutes()
    end
    if (timeleft < 0)
       # we are over desired limit already, no benefits
       time = 0
    end
    # TODO: add checks that the observation can actually be
    # made
    # if (!j.isAvailable(entry.getKey()))
    #    time = 0
    # end
    # TODO: add benefit based on observation conditions
    
    Math.exp(j.proposal.priority) * time / LST_SLOTS_MINUTES
  end
end

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
    
    schedule_space = schedule_factory.getScheduleSpace( proposal_set, guard, 10 )
    puts "got a schedule space", schedule_space.to_string
    
    run_schedulers(schedule_space)
  end
  
  def run_schedulers(schedule_space)
        # Lets generate a few prior schedules from heuristics first
    cpu = Java::LocalRadioschedulersCpu::CPULikeScheduler
    rand = cpu.new(Java::LocalRadioschedulersCpu::RandomizedSelector.new)
    schedulers = [
       cpu.new(Java::LocalRadioschedulersCpu::FirstSelector.new),
       cpu.new(Java::LocalRadioschedulersCpu::FairPrioritizedSelector.new),
       cpu.new(Java::LocalRadioschedulersCpu::PrioritizedSelector.new),
       cpu.new(Java::LocalRadioschedulersCpu::ShortestFirstSelector.new), 
       rand, rand, rand, 
       rand
    ]
    schedulers.push(Java::LocalRadioschedulersLp::ParallelLinearScheduler.new)
    prior_schedules = {}
    puts 'prior schedulers', schedulers
    i = 0
    schedulers.each do |scheduler|
      puts "scheduling with", scheduler
      schedule = scheduler.schedule(schedule_space)
      prior_schedules["Schedule #{i} - #{scheduler}"] = schedule
      i = i + 1
    end
    
    puts "got prior schedules", prior_schedules
    @priors = writeschedules_to_static_files(prior_schedules, "prior")
    
    schedules = run_ga_scheduler(schedule_space, prior_schedules.values)
    puts "got schedules", schedules
    @files = writeschedules_to_static_files(schedules, "schedule")
  end
  
  def run_ga_scheduler(schedule_space, prior_schedules)
    schedulerclass = Java::LocalRadioschedulersGaJgap::JGAPScheduler
    #fitness = Java::LocalRadioschedulersGaFitness::SimpleScheduleFitnessFunction.new
    fitness = MyFitnessFunction.new
    fitness.setSwitchLostMinutes(0)
    
    scheduler = schedulerclass.new(fitness)
    scale = 10
    # scale = 1 # quick testing
    scheduler.number_of_generations = 10 * scale
    scheduler.setPopulationSize(10 * scale)
    scheduler.setPopulation(prior_schedules)
    scheduler.schedule(schedule_space)
    intermediate = scheduler.getPopulation()
    puts "got intermediate population", intermediate
    intermediate = intermediate + prior_schedules
    fitness.setSwitchLostMinutes(60)
    
    scheduler = schedulerclass.new(fitness)
    scheduler.setNumberOfGenerations(10 * scale)
    scheduler.setPopulationSize(4 * scale)
    scheduler.setPopulation(intermediate)
    scheduler.schedule(schedule_space)
    
    return scheduler.getPopulation()
  end
  
  def writeschedules_to_static_files(schedules, prefix)
    files = []
    i = 0
    schedules.each do |s|
      if (s.class == Array)
        inter = ".#{s[0]}."
        s = s[1]
      else
        inter = '.'
      end
      filename = "public/schedules/#{prefix}#{inter}#{i}.html"
      files.push("/schedules/#{prefix}#{inter}#{i}.html")
      exporter = Java::LocalRadioschedulersExporter::HtmlExport.new(
        Java::JavaIO::File.new(filename), s.to_string)
      exporter.export(s)
      i = i + 1
    end
    files
  end
  
end
