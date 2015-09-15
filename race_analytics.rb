require_relative 'race_base'
require_relative 'runnerHelpers'

#p RaceEntry.all(:race_name => "Московский полумарафон 2014. 21 км").min(:chip_time)
#p RaceEntry.all(:race_name => "Московский полумарафон 2014. 21 км").max(:chip_time)


#RaceEntry.all(:race_name => "Московский полумарафон 2014. 21 км").each do |entry|
#  p entry.totalMinutes()
#end

def minutesToTime(totalMinutes)
  minutes = totalMinutes % 60
  hours = (totalMinutes.to_f / 60).floor
  
  "%02d" % hours + ':' + "%02d" % minutes
end

DataMapper.auto_upgrade!



class RaceStats
  def getRaceMedian(race_id)
    people = RaceEntry.all(:race => {:id => race_id}, :gender=>"f", :order =>[:chip_time.desc])
    middle = (people.count.to_f / 2).ceil

    RunnerTime.timeToTimeOfDay(people[middle].chip_time)
  end
  
  def getRaceMedianPace(race_id, gender)
    people = RaceEntry.all(:race => {:id => race_id}, :gender=>gender, :order =>[:chip_time.desc])
    middle = (people.count.to_f / 2).ceil
    distance = Race.get(race_id).distance
    RunnerTime.timeToPace(people[middle].chip_time, distance).values
  end

  def getRaceChipTimeGraph(race_id)
    people = RaceEntry.all(:race_id => race_id, :order =>[:chip_time.asc])
    return people.chunk {|e| (e.totalMinutes().to_f / 5).ceil}.sort.map {|x,y| [x*5, y.count]}
  end
  
  def getChipTimeGraphForArrray(people, type, ticksSeconds)
    sorted = people.sort_by {|p| p.chip_time}
    
    if type == :pace
      sorted.chunk {|e| (e.paceSeconds()/ticksSeconds).floor}.sort.map {|x,y| 
				[RunnerTime.secondsToPaceString(x*ticksSeconds), y.count]
			}
    elsif type == :paceTimeOfDay
      sorted.chunk {|e| (e.paceSeconds()/ticksSeconds).floor}.sort.map {|x,y| 
				[RunnerTime.secondsToPace(x*ticksSeconds), y.count]
			}
    elsif type == :finishTime
      distance = sorted.first.race.distance
#      sorted.chunk {|e| (e.totalMinutes()/(ticksSeconds/60)).ceil}.sort.map {|x,y| [RunnerTime.minutesToTimeString(x*ticksSeconds/60), y.count]}      
      sorted.chunk {|e| (e.totalMinutes()/(ticksSeconds/60)).ceil}.sort.map {|x,y| [x*ticksSeconds/60, y.count]}
    elsif type == :finTimeOfDay       
      sorted.chunk {|e| (e.totalMinutes()/(ticksSeconds/60)).ceil}.sort.map {|x,y| 
				[RunnerTime.secondsToTimeOfDay(x*ticksSeconds), y.count]
			}
    end
  end
  
  def getPaceForArray(people, distance, ticks)
      sorted = people.sort_by {|p| p.chip_time}
  end
  
  def getPaceComparison(people1, people2, ticksSeconds)
    table = (12..48).map{|a| [RunnerTime.secondsToPace(a*ticksSeconds), 0,0]}
    
    r1 = getChipTimeGraphForArrray(people1, :paceTimeOfDay, ticksSeconds)
    r2 = getChipTimeGraphForArrray(people2, :paceTimeOfDay, ticksSeconds)
    
    table.each {|r|
      i1 = r1.index{|n| n[0] == {:hours => r[0][:hours], :minutes => r[0][:minutes], :seconds => r[0][:seconds]}}
      i2 = r2.index{|n| n[0] == {:hours => r[0][:hours], :minutes => r[0][:minutes], :seconds => r[0][:seconds]}}
      
      if (i1 != nil)
        r[1] = r1[i1][1]
      end
      
      if (i2 != nil)
          r[2] = r2[i2][1]
      end
    }
    
    table.delete_if {|i| i[1] == 0 && i[2] == 0}
    table
  end

  def getGenderDistribution(race_id)
    male = RaceEntry.all(:race => {:id => race_id}, :gender => "m").count
    female = RaceEntry.all(:race => {:id => race_id}, :gender => "f").count
    
    return {:m => male, :f => female}
  end

  def getAgeGroupDistribution(race_id)
    result = DataMapper.repository.adapter.select("SELECT age_group, count(*) as count FROM race_entries WHERE race_id = #{race_id} GROUP BY age_group")
    x = result.map {|x| [x.age_group, x.count]}
    x
  end
  
  def getParticipantsCount()
    result = DataMapper.repository.adapter.select("SELECT race_id, SUM(Case gender when 'f' then 1 else 0 end) as female, SUM(Case gender when 'm' then 1 else 0 end) as male  FROM race_entries GROUP BY race_id")
    
    x = result.map{|a| [a.race_id, a.male, a.female]}
    x
  end
end

#rs = RaceStats.new

#p rs.getRaceMedian(1)
#p rs.getGenderDistribution(1)
#rs.getAgeGroupDistribution(1)




=begin
male = RaceEntry.all(:race_name => "Московский полумарафон 2014. 21 км", :gender => "m", :order =>[:chip_time.asc])
female = RaceEntry.all(:race_name => "Московский полумарафон 2014. 21 км", :gender => "f", :order =>[:chip_time.asc])

maleMusic = RaceEntry.all(:race_name => "Музыкальный полумарафон 2014. 21 км", :gender => "m", :order =>[:chip_time.asc])
femaleMusic = RaceEntry.all(:race_name => "Музыкальный полумарафон 2014. 21 км", :gender => "f", :order =>[:chip_time.asc])

center = male.count/2
p male[center].chip_time

center = maleMusic.count/2
p maleMusic[center].chip_time

center = female.count/2
p female[center].chip_time

center = femaleMusic.count/2
p femaleMusic[center].chip_time

maleGroups = male.chunk {|e| (e.totalMinutes().to_f / 5).ceil}.sort.map {|x,y| [x*5, y.count]}
femaleGroups = female.chunk {|e| (e.totalMinutes().to_f / 5).ceil}.sort.map {|x,y| [x*5, y.count]}
maleMusicGroups = maleMusic.chunk {|e| (e.totalMinutes().to_f / 5).ceil}.sort.map {|x,y| [x*5, y.count]}
femaleMusicGroups = femaleMusic.chunk {|e| (e.totalMinutes().to_f / 5).ceil}.sort.map {|x,y| [x*5, y.count]}

text = ""
maleGroups.each do |key|
  text += "{x: '2014-01-01 #{minutesToTime(key[0])}:00', y: #{key[1]}, group: 0}, "
end

femaleGroups.each do |key|
  text += "{x: '2014-01-01 #{minutesToTime(key[0])}:00', y: #{key[1]}, group: 1}, "
end

maleMusicGroups.each do |key|
  text += "{x: '2014-01-01 #{minutesToTime(key[0])}:00', y: #{key[1]}, group: 2}, "
end

femaleMusicGroups.each do |key|
  text += "{x: '2014-01-01 #{minutesToTime(key[0])}:00', y: #{key[1]}, group: 3}, "
end

p text
=end 


=begin
@male = DataMapper.repository.adapter.select(
  'SELECT strftime("%H:%M", chip_time, "localtime") as time, count(id) as Count FROM race_entries WHERE race_name="Московский полумарафон 2014. 21 км" AND gender="m" GROUP BY strftime("%H:%M", chip_time, "localtime")');
  
@female = DataMapper.repository.adapter.select(
    'SELECT strftime("%H:%M", chip_time, "localtime") as time, count(id) as Count FROM race_entries WHERE race_name="Московский полумарафон 2014. 21 км" AND gender="f" GROUP BY strftime("%H:%M", chip_time, "localtime")');
  
@male.each do |entry|
  p entry.time[3..4].to_i
end
  
x = 0
text = ""
@male.each() {|entry|
  p "#{entry.time} - #{entry.count}"
  text += "{x: '2014-01-01 #{entry.time}:00', y: #{entry.count}, group: 0}, "
  }
  
@female.each() {|entry|
    p "#{entry.time} - #{entry.count}"
    text += "{x: '2014-01-01 #{entry.time}:00', y: #{entry.count}, group: 1}, "
    }
  
p text
=end
