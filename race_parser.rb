require_relative 'race_base'
require 'json'

class RaceParser
  def parse_3sport
      url = 'https://data.3sport.org/vg-2014/events/28/results/gender/M?page=2'
      
      document = Nokogiri::HTML(open(url))
      
      document.css('table tbody tr')
      
  end
  
  def parse_json_10k(filename, gender, race_id)
    text = ""
    File.open(filename) do |f|
      while line = f.gets
        text += line
      end
    end

    x = JSON.parse(text)
    
    mm = Race.get(race_id)

    arr = x['data']

    arr.each {|e|
      r = RaceEntry.new
      r.bib = e[1]
      r.name = e[2] + ' ' + e[3]

      age = e[4]
      
      r.age_group = case age
      when 10..19 then '18-19'
      when 20..22 then '20-22'
      when 23..34 then '23-34'
      when 35..39 then '35-39'
      when 40..44 then '40-44'
      when 45..49 then '45-49'
      when 50..54 then '50-54'
      when 55..59 then '55-59'
      when 60..65 then '60-65'
      when 65..100 then '65+'
      end

      r.gender = gender
      r.chip_time = Time.parse(e[8]) 
      r.official_time = Time.parse(e[9]) 
      r.race = mm
      r.save
      puts r
    }
  end
end