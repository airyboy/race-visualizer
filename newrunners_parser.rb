require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'data_mapper'
require 'dm-core'
require 'time'

DataMapper.setup( :default, "sqlite3://#{File.dirname(__FILE__)}/race.db" )

class RaceEntry
	include DataMapper::Resource

	property :id, Serial, :key => true
	property :race_name, String
  	property :age_group, String
  	property :gender, String
  	property :bib, String
  	property :name, String
  	property :chip_time, DateTime
  	property :official_time, DateTime

	def to_s
		"#{@race_name};#{@gender};#{@age_group};#{@bib};#{@name};#{@chip_time};#{@official_time}"
	end
end

DataMapper.auto_upgrade!  

def getLastPage(doc)
	paginator = doc.css("div.pagination ul li")

	if paginator.count == 0
		return 1
	end

	last_page = paginator[paginator.count - 2].inner_html()[/.*page=(\d{1,2})/,1].to_i

	last_page	
end


def extractTableData(doc, entry_prototype)
  table = doc.css("div.result_stats table tbody tr")

  people = Array.new

  table.each {|e| 
  	entry = RaceEntry.new
  	entry.race_name = entry_prototype.race_name
  	entry.age_group = entry_prototype.age_group
  	entry.gender = entry_prototype.gender

 	  entry.name = "'#{e.xpath("td[2]/a/p").inner_html().gsub(/\s+/, '').gsub(/<br>/, ' ')}'"
  	entry.bib = e.xpath("td[5]").text().gsub(/\s+/, '')
  	entry.chip_time = Time.parse(e.xpath("td[6]/p").text().gsub(/\s+/, ''))
  	entry.official_time = Time.parse(e.xpath("td[7]/p").text().gsub(/\s+/, ''))
    entry.save
    
  	people << entry
  }

  people
end

def parseRace(url, len, race_name)
	age = [18, 20, 23, 35, 40, 45, 50, 55, 60, 65]

	gender = [1, 2]

	#age = [18]
	#gender = [1]

	urls = Hash.new

	gender.each {|sex|
		ages = Hash.new
		age.each() {|a| 
			ages[a] = "#{url}/past/results?gender=#{sex}&length=#{len}&protocol=#{a}"
		}	
		urls[sex] = ages
	}

	#puts urls
	#urls.each {|a| puts a}
	gender.each {|sex|
		age.each() {|a|
			doc = Nokogiri::HTML(open(urls[sex][a]))	
			last = getLastPage(doc)

			(1..last).each do |i|
				url = "#{urls[sex][a]}&page=#{i}"
				puts url
				
				document = Nokogiri::HTML(open(url))
				
				entry_proto = RaceEntry.new
				entry_proto.race_name = race_name	
				
				if sex == 1
				  entry_proto.gender = "m"
				else 
				  entry_proto.gender = "f"
			  end
				
				case a
			  when 18
				  entry_proto.age_group = '18-19'
			  when 20
			    entry_proto.age_group = '20-22'
			  when 23
  	      entry_proto.age_group = '23-34'
  			when 35
    	    entry_proto.age_group = '35-39'
		    when 40
			    entry_proto.age_group = '40-44'
      	when 45
        	entry_proto.age_group = '45-49'
        when 50
          entry_proto.age_group = '50-54'
        when 55
          entry_proto.age_group = '55-59'
        when 60
          entry_proto.age_group = '60-65'
        when 65
          entry_proto.age_group = '65+'
        end
				
				people = extractTableData(document, entry_proto)

				#people.each() {|p| puts p.to_s}
			end	
		}
	} 
end

#doc = Nokogiri::HTML(open('http://newrunners.ru/race/muzykalnyj-polumarafon-2014/past/results/?gender=2&length=21&protocol=23&page=2&text='))
#doc = Nokogiri::HTML(open("http://newrunners.ru/race/moskovskij-marafon/past/results/?gender=2&length=42&text=&protocol=40#"))

#RaceEntry.destroy
#parseRace('http://newrunners.ru/race/moskovskij-marafon', 10, "Московский марафон 2013. 10 км (11.6 км)")
#parseRace('http://newrunners.ru/race/moskovskij-marafon', 42, "Московский марафон 2013. 42 км")
#parseRace('http://newrunners.ru/race/muzykalnyj-polumarafon-2014', 21, "Музыкальный полумарафон 2014. 21 км")
#parseRace('http://newrunners.ru/race/muzykalnyj-polumarafon-2014', 10, "Музыкальный полумарафон 2014. 10 км")
#parseRace('http://newrunners.ru/race/moskovskij-polumarafon', 10, "Московский полумарафон 2014. 10 км")
#parseRace('http://newrunners.ru/race/moskovskij-polumarafon', 21, "Московский полумарафон 2014. 21 км")
parseRace('http://newrunners.ru/race/pervyj-zabeg-2014',5,"Первый забег 2014")

#x = Time.parse('4:58:27')

#p x











