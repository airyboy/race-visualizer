require 'rubygems'
require 'data_mapper'
require 'dm-core'
require 'time'
require_relative 'runnerHelpers'

DataMapper.setup( :default, "sqlite3://#{File.dirname(__FILE__)}/race.db" )

class RaceEntry
	include DataMapper::Resource

	property :id, Serial, :key => true
	property :age_group, String
	property :gender, String
	property :bib, String
	property :name, String
	property :chip_time, DateTime
	property :official_time, DateTime

  belongs_to :race, :required => false

  def totalMinutes()
    x = self.chip_time.strftime('%H').to_i * 60 + self.chip_time.strftime('%M').to_i
    
    return x
  end
  
  def paceString()
    seconds = self.chip_time.strftime('%H').to_i * 60 * 60 + self.chip_time.strftime('%M').to_i * 60 + self.chip_time.strftime('%S').to_i
    paceSeconds = seconds.to_f / self.race.distance.to_f
    
    minutes = (paceSeconds / 60).floor
    secs = paceSeconds % 60
    
    return "#{"%02d" % minutes}:#{"%02d" % secs}"
  end
  
  def totalSeconds()
    self.chip_time.strftime('%H').to_i * 60 * 60 + self.chip_time.strftime('%M').to_i * 60 + self.chip_time.strftime('%S').to_i
  end
  
  def paceSeconds()
    totalSeconds()/self.race.distance
  end

	def to_s
		"#{@race_name};#{@gender};#{@age_group};#{@bib};#{@name};#{@chip_time};#{@official_time}"
	end
end

class Race
  include DataMapper::Resource
  
  property :id, Serial, :key => true
	property :race_name, String
	property :distance, Decimal
	property :date, DateTime
	
	has n, :raceEntry	
	
	def to_s
		"#{id};#{@race_name};#{@distance}"
	end
end