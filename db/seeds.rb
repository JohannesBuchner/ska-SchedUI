# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

sr1 = Source.create( :name => 'Orion', :catalog => 'Standard', :ra => 5.91952, :dec => 7.40705, :type=>'S' )
sr2 = Source.create( :name => '3c286', :catalog => 'Standard', :ra => 13.518969, :dec => 30.509155, :type=>'C' )
sr3 = Source.create( :name => '3c84', :catalog => 'Standard', :ra => 3.330044, :dec => 41.511695, :type=>'C' )


p1 = Proposal.create( :name => 'Orion Sched1', :priority=>10.0 )
p2 = Proposal.create( :name => 'Taurus Sched2', :priority=>5.0 )
p3 = Proposal.create( :name => 'Gemini Sched3', :priority=>7.0 )

jb1 = Job.create( :startlst => 1.0, :endlst => 6.0, :totalhours => 80.0, :proposal_id=>p1.id )
jb2 = Job.create( :startlst => 5.0, :endlst => 12.0, :totalhours => 120.0, :proposal_id=>p2.id )
jb3 = Job.create( :startlst => 3.0, :endlst => 20.0, :totalhours => 30.0, :proposal_id=>p3.id )

bd1 = BadDate.create( :job_id => jb1.id, :start => Time.current, :end => Time.current + (3600*24) )
bd2 = BadDate.create( :job_id => jb1.id, :start => Time.current + (3600*24*5), :end => Time.current + (3600*24*6) )

