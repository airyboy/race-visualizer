require 'time'

class RunnerTime
  
  def self.timeToPace(time, distance)
    seconds = time.strftime('%H').to_i * 60 * 60 + time.strftime('%M').to_i * 60 + time.strftime('%S').to_i
    paceSeconds = seconds.to_f / distance.to_f
    
    minutes = (paceSeconds / 60).floor
    secs = (paceSeconds % 60).round(0).to_i
    
    return {:hours => 0, :minutes => minutes, :seconds => secs}
  end
  
  def self.timeToTimeOfDay(time)
    [time.hour, time.min, time.sec]
  end
  
  def self.timeToPaceString(time, distance)
    res = RunnerTime.timeToPace(time, distance)
    return "#{"%02d" % res[:minutes]}:#{"%02d" % res[:seconds]}"
  end
  
  def self.timeToPaceTime(time, distance)
    res = RunnerTime.timeToPace(time, distance)    
    t = Time.new(2000,1,1,0,res[:minutes], res[:seconds])
    return t
  end
  
  def self.secondsToPace(seconds)
    return {:hours => 0, :minutes => (seconds / 60).floor, :seconds => seconds % 60}
  end
  
  def self.secondsToTimeOfDay(seconds)
    hours = (seconds/(60*60)).floor
    restMinutes = ((seconds - hours * 60 * 60)/60).floor
    restSeconds = (seconds - hours * 60 * 60 - restMinutes * 60)
    return {:hours => hours, :minutes => restMinutes, :seconds => restSeconds}
  end
  
  def self.secondsToPaceString(seconds)
    res = RunnerTime.secondsToPace(seconds)
    
    return "#{"%02d" % res[:minutes]}:#{"%02d" % res[:seconds]}"
  end
  
  def self.secondsToPaceTime(seconds)
    res = RunnerTime.secondsToPace(seconds)
    
    return Time.new(2000,1,1,0,res[:minutes], res[:seconds])
  end
  
  def self.minutesToTimeString(minutes)
    return "#{"%02d" % (minutes.to_f/60).floor}:#{"%02d" % (minutes % 60)}"
  end
  
end