
require 'rubygems'
require 'java'
import 'java.util.HashSet'
import 'java.util.ArrayList'

FitnessFunc = Java::LocalRadioschedulersAlgGaFitness::SimpleScheduleFitnessFunction
LST_SLOTS_MINUTES = Java::LocalRadioschedulers::Schedule::LST_SLOTS_MINUTES
class MyFitnessFunction < FitnessFunc
  alias :super_evaluateSlotJob :evaluateSlotJob
  
  # @param job Job
  # @param timeleft long, minutes
  # @param inPreviousSlot boolean
  def evaluateSlotJob(j, timeleft, inPreviousSlot)
    time = super_evaluateSlotJob(j, timeleft, inPreviousSlot)
    if (inPreviousSlot)
       time = LST_SLOTS_MINUTES
    else
       time = LST_SLOTS_MINUTES - getSwitchLostMinutes()
       if time < 0
          time = 0
       end
    end
    if (timeleft < 0)
       # we are over desired limit already, no benefits
       time = 0
    end
    # TODO: add benefit based on observation conditions 
    # TODO: add benefit based on scheduler preferences
    
    return time
  end
end

# TODO, check return on queries for nil results
# for error handling

class RescheduleController < ApplicationController
  def new
    proposal_set = load_proposals
    ndays = 10
    schedule_space = calc_schedule_space proposal_set, ndays
    
    puts "got a schedule space", schedule_space.to_string
    
    run_schedulers(schedule_space)
  end
  
  # This is a bit crazy
  def load_proposals
    # first, gather all proposals
    all_proposals = Proposal.all
    proposal_set = HashSet.new
    
    # loop over proposals building java data structures
    # gather local reference to Java Proposal type
    # and Java Job type
    j_proposal = Java::LocalRadioschedulers::Proposal
    j_job  = Java::LocalRadioschedulers::JobWithResources
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
        jj.id = j.id.to_s

        # Constraints contain info about the job
        # TODO: will there ever be multiple constraints per job?
        # based on this usage, there should never be..
        # TODO: Check return!

        jj.hours = j.totalhours

        jj.lstmin = j.startlst
        jj.lstmax = j.endlst
        
        jj.date = Java::LocalRadioschedulersPrescheduleDate::NoDateRequirements.new
        
        # TODO: load from proposal
        
        rr = Java::LocalRadioschedulers::ResourceRequirement.new
        rr.possibles.addAll((0..42).to_a)
        rr.numberrequired = 42
        jj.resources["antennas"] = rr
        
        # TODO: add Backend
        
        job_set.add(jj)
      end # all_jobs_by_proposal.each
      jp.jobs = job_set
      
      proposal_set.add(jp)
    end # all_proposals.each
    return proposal_set 
  end
  
  def calc_schedule_space(proposal_set, ndays)
    schedule_factory = Java::LocalRadioschedulersApi::SchedulePipeline.new
    guard = Java::LocalRadioschedulersPrescheduleParallel::ParallelRequirementGuard.new
    
    schedule_space = schedule_factory.getScheduleSpace( proposal_set, guard, ndays )
  end
  
  def run_schedulers(schedule_space)
    # Lets generate a few prior schedules from heuristics first
    serial   = Java::LocalRadioschedulersAlgSerial::SerialListingScheduler
    parallel = Java::LocalRadioschedulersAlgParallel::TrivialFirstParallelListingScheduler
    
    schedulers = [
      serial.new(Java::LocalRadioschedulersAlgSerial::PrioritizedSelector.new),
      parallel.new(Java::LocalRadioschedulersAlgParallel::PriorityJobSortCriterion.new)
    ]
    prior_schedules = {}
    puts 'prior schedulers', schedulers
    i = 0
    schedulers.each do |scheduler|
      puts "scheduling with", scheduler
      schedule = scheduler.schedule(schedule_space)
      prior_schedules["Schedule-#{i}-#{scheduler.to_s}"] = schedule
      i = i + 1
    end
    
    puts "got prior schedules", prior_schedules
    #@priors = writeschedules_to_static_files(prior_schedules, "prior")
    # store in db?
    # storeschedules(prior_schedules, "prior")
    
    schedules = prior_schedules
    #schedules = run_ga_scheduler(schedule_space, prior_schedules.values)
    puts "got schedules", schedules
    @time = Time.now.to_i
    @files = writeschedules_to_static_files(schedules, "#{@time}/")
    # store in db?
    # storeschedules(schedules, "schedule")
    
    #redirect_to "/view/#{time}"
    # redirect_to :action => 'show', :time => time
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
  
  def storeschedules(schedules, prefix)
    i = 0
    schedules.each do |s|
      if (s.class == Array)
        inter = ".#{s[0]}."
        s = s[1]
      else
        inter = '.'
      end
      
      rs = Schedule.new
      rs.name = "#{prefix}#{inter}#{i}.html"
      rs.enabled = true
      rs.favorite = false
      # filling the schedule
      rs.ScheduleContent_ids = []
      puts "storing #{rs.name}"
      rs.save!
      t = 0
      s.each do |k|
        if (not k.value.nil?)
          puts "  t = #{k.key} (#{t})"
          k.value.jobs.each do |j|
            ss = ScheduleContent.new
            ss.timeslot = t
            ss.Schedule_id = rs
            ss.Job_id = Job.find_by_id(j.id)
            ss.save!
            rs.ScheduleContent_ids.push(ss)
          end
        end
        t = t + 1
      end
      #rs.save!
      i = i + 1
    end
    
  end
  
  def set_schedules_root
    @schedules_root = "public/schedules/"
  end
  
  def writeschedules_to_static_files(schedules, prefix)
    files = []
    i = 0
    set_schedules_root
    schedules.each do |s|
      if (s.class == Array)
        name = s[0].to_s
        s = s[1]
      else
        name = s.to_s
      end
      inter = ''
      unless prefix.ends_with? "/" or prefix.ends_with "-"
        inter = "-" + inter
      end
      
      filename = "#{@schedules_root}/#{prefix}#{inter}#{i}.html"
      puts filename
      files.push("/schedules/#{filename}")
      file = Java::JavaIO::File.new(filename)
      # make sure parent folder exists
      file.parent_file.mkdirs()
      exporter = Java::LocalRadioschedulersExporter::HtmlExport.new(
        file, name)
      exporter.export(s)
      filename = "#{@schedules_root}/#{prefix}#{inter}#{i}.csv"
      exporter = Java::LocalRadioschedulersExporter::CsvExport.new(
        Java::JavaIO::File.new(filename))
      exporter.export(s)
      i = i + 1
    end
    files
  end
  
  def index
    show
  end
  
  def show
    set_schedules_root
    time = params[:time]
    id = params[:filename]
    print "params: " + params.to_s + "\n"
    # load list in directory
    
    tree = {}
    
    Dir.new(@schedules_root).each do |d|
      unless ['.', '..'].include? d
        dn = "#{@schedules_root}/#{d}"
        if File.directory?(dn)
          list = []
          Dir.new(dn).each do |file|
            fn = "#{dn}/#{file}"
            if not ['.', '..'].include? file and File.file?(fn) and file.end_with?(".csv")
              list.push(file)
            end
          end
          tree[d] = list
        end
      end
    end
    dirs = tree.keys.sort()
    @schedule_tree = tree
    
    # load latest schedule if time is undefined
    if time == nil
      time = dirs.first
    end
    if id == nil
      unless tree.empty?
        id = tree[time].first
      end
    end
    @schedule_tree_selected = "#{time}/#{id}"
    
    # load proposals
    @proposals = load_proposals
    if @proposals == nil
      throw Exception.new "no proposals"
    end
    ndays = 10
    @schedule_space = calc_schedule_space @proposals, ndays
    
    # load schedule and match with proposals
    filename = "#{@schedules_root}/#{time}/#{id}"
    unless filename.end_with? ".csv"
      filename += ".csv"
    end
    puts "filename", filename
    file = Java::JavaIO::File.new(filename)
    if file.exists? and file.is_file?
      importer = Java::LocalRadioschedulersImporter::CsvScheduleReader.new(
          nil, nil, @proposals)
      @schedule = importer.read file
    end
    
    # now the view has to display the schedule and the schedule tree.
  end
end

