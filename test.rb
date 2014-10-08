require_relative 'runnerHelpers'
require_relative 'race_analytics'
require 'json'
require_relative 'race_parser'


#rp = RaceParser.new
#rp.parseJson10k('/Users/mike/Downloads/10km-female.json', 'f', 10)


#t = Time.new(2010,1,1,3,50)

#p RunnerTime.timeToPaceString(t, 42.195)
#p RunnerTime.timeToPaceTime(t, 42.195)

#p RunnerTime.secondsToPaceString(300)

rs = RaceStats.new
#arr = rs.getParticipantsCount()
#a1 = arr.map{|a| [Race.get(a[0]).race_name, a[1], a[2]]}

#p a1

rs.getAgeGroupDistribution(9).each{|a| p a}

p Race.get(9)
p Race.get(2)
#r1 = RaceEntry.all(:race_id=> 9,  :order =>[:chip_time.asc])
#r2 = RaceEntry.all(:race_id=> 2,  :order =>[:chip_time.asc])
#x = rs.getAgeGroupDistribution(r1)
  


#male.each {|e| p [e.name, e.chip_time, e.paceString]}
#m = RaceEntry.first(:race_id => 1)
#p m.paceSeconds()
#p male.chunk {|e| (e.paceSeconds()/30).ceil}.each {|e,c| p [RunnerTime.secondsToPaceString(e*30), c.count]}

=begin
x = rs.getChipTimeGraphForArrray(male, :finishTime, 2*60)

data = Hash[x.map.with_index.to_a].map{|x,y| [y,x[1]]}
markers = Hash[x.map.with_index.to_a].map{|x,y| [y,x[0]]}

p data 
p markers

=end 

=begin
mm = Race.new
mm.distance = 10
mm.race_name = 'Московский марафон. 10 км'
mm.save

p mm


mm = Race.get(10)

text = ""
File.open('/Users/mike/Downloads/10km-male.json') do |f|
  while line = f.gets
    text += line
  end
end

x = JSON.parse(text)

arr = x['data']

arr.each {|e|
  r = RaceEntry.new
  r.bib = e[1]
  r.name = e[2] + ' ' + e[3]
  
  if e[10][0] == 'М'
    r.gender = 'm'
  elsif e[10][0] == 'Ж'
    r.gender = 'f'
  end
  
  age = e[10][1..2]
  
  r.age_group = case age
  when '18' then '18-19'
  when '20' then '20-22'
  when '23' then '23-34'
  when '35' then '35-39'
  when '40' then '40-44'
  when '45' then '45-49'
  when '50' then '50-54'
  when '55' then '55-59'
  when '60' then '60-65'
  when '65' then '65+'
  end
  
  r.chip_time = Time.parse(e[8]) 
  r.official_time = Time.parse(e[9]) 
  r.race = mm
  
  r.save
  p r
  }

#x.each_key do |key|
#  p x[key].class
#end


#  races = Race.all.map {|x| [x.id, x.race_name]}
  
#  p races


#rs.getAgeGroupDistribution(2)

=begin
t = Race.new
t.race_name = "Первый забег 2014 (5 км)"
t.distance = 5
t.save
=end

