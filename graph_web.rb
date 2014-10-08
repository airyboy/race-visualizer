require 'rubygems'
require 'haml'
require 'sinatra'
require_relative 'race_analytics'
require 'json'

get '/' do
  @races = Race.all.map {|x| [x.id, x.race_name]}
  
  haml :"graph"
end

get '/participants' do
  rs = RaceStats.new  
  arr = rs.getParticipantsCount()
  female = arr.map.with_index.to_a.map{|a| [a[0][2], a[1]]}
  male = arr.map.with_index.to_a.map{|a| [a[0][1], a[1]]}
  labels = arr.map.with_index.to_a.map{|a| [a[1], Race.get(a[0][0]).race_name]}
  
  content_type :json;
  
  {:male => male, :female => female, :labels =>labels}.to_json
end

get '/peopleCount' do
  rs = RaceStats.new  
  arr = rs.getParticipantsCount()
  
  content_type :json
  
  titles = ["Name", "Male", "Female"]
  data = arr.map{|a| [Race.get(a[0]).race_name, a[1], a[2]]}
  
  {:titles => titles, :data => data}.to_json
end

get '/ageGroup' do
  race_id = 1
  if params[:race_id] != nil
    race_id = params[:race_id].to_i
  end
  
  p params[:race_id]
  p race_id
  
  rs = RaceStats.new  
  age_distr = rs.getAgeGroupDistribution(race_id)  
  content_type :json
  age_distr.to_json
end

get '/gender' do
  race_id = 1
  if [params[:race_id]] != nil
    race_id = params[:race_id].to_i
  end
  
  rs = RaceStats.new  
  gender_distr = rs.getGenderDistribution(race_id)  
  content_type :json;
  gender_distr.to_json
end

get '/gr' do
  race_id = 1
  if [params[:race_id]] != nil
    race_id = params[:race_id].to_i
  end
  
  rs = RaceStats.new
  #all = RaceEntry.all(:race_id=> race_id, :order =>[:chip_time.asc])
  male = RaceEntry.all(:race_id=> race_id, :gender => 'm', :order =>[:chip_time.asc])
  female = RaceEntry.all(:race_id=> race_id, :gender => 'f', :order =>[:chip_time.asc])
  
  minutes_ticks = 1
  #race params
  race = male[0].race
  
  case race.distance.to_i
  when 1..5
    minutes_ticks = 2
  when 6..10
    minutes_ticks = 3
  when 11..21
    minutes_ticks = 5
  when 22..50
    minutes_ticks = 10
  end
          
  male_perf = rs.getChipTimeGraphForArrray(male, :finTimeOfDay, minutes_ticks*60).map{|a| [a[0].values, a[1]]}
  female_perf = rs.getChipTimeGraphForArrray(female, :finTimeOfDay, minutes_ticks*60).map{|a| [a[0].values, a[1]]}

  title = male[0].race.race_name
  content_type :json;
=begin
  {:all => Hash[all_perf.map.with_index.to_a].map{|x,y| [y,x[1]]}, 
    :male => Hash[male_perf.map.with_index.to_a].map{|x,y| [y,x[1]]},
    :female => Hash[female_perf.map.with_index.to_a].map{|x,y| [y,x[1]]},
    :markers => markers, :race => title}.to_json;
=end
  { :male => male_perf,
    :female => female_perf,
    :title => title}.to_json;
end

get '/races' do
  races = Race.all.map {|x| [x.id, x.race_name]}
  content_type :json
  races.to_json
end

get '/compare' do
  @races = Race.all.map {|x| [x.id, x.race_name]}
  
  haml :"compare"
end

get '/racePerf' do
  r1_id = params[:race1].to_i
  r2_id = params[:race2].to_i
  
  rs = RaceStats.new
  r1 = RaceEntry.all(:race_id=> r1_id,  :order =>[:chip_time.asc])
  r2 = RaceEntry.all(:race_id=> r2_id,  :order =>[:chip_time.asc])
  data =  rs.getPaceComparison(r1, r2, 10).map{|a| [a[0].values, a[1], a[2]]}
  
  #express data in percent
  if (params[:percent] == 'true')
    sum_r1 = data.inject(0.0) {|sum, a| sum + a[1].to_f }
    sum_r2 = data.inject(0.0) {|sum, a| sum + a[2].to_f }
    
    data.each() do |e|
      e[1] = (e[1].to_f*100/sum_r1).round(2)
      e[2] = (e[2].to_f*100/sum_r2).round(2)
    end
  end
  
  r1_name = Race.get(r1_id).race_name
  r2_name = Race.get(r2_id).race_name
  
  content_type :json
  
  {:data => data, :race1_title => r1_name, :race2_title => r2_name}.to_json
end

get '/gender_comparison' do
  r1_id = params[:race1].to_i
  r2_id = params[:race2].to_i
  
  rs = RaceStats.new
  r1_distr = rs.getGenderDistribution(r1_id)  
  r2_distr = rs.getGenderDistribution(r2_id)
  
  #express data in percent
  if (params[:percent] == 'true')
    sum_r1 = r1_distr[:m] + r1_distr[:f]
    sum_r2 = r2_distr[:m] + r2_distr[:f]
    
    r1_distr[:m] = (r1_distr[:m]*100/sum_r1.to_f).round(2)
    r1_distr[:f] = (r1_distr[:f]*100/sum_r1.to_f).round(2)
    r2_distr[:m] = (r2_distr[:m]*100/sum_r2.to_f).round(2)
    r2_distr[:f] = (r2_distr[:f]*100/sum_r2.to_f).round(2)
  end  
  
  r1_name = Race.get(r1_id).race_name
  r2_name = Race.get(r2_id).race_name
  
  arr = [r1_distr.values.unshift(r1_name), r2_distr.values.unshift(r2_name)]
  p arr
  
  content_type :json
  {:data => arr}.to_json
end

get '/age_comparison' do
  r1_id = params[:race1].to_i
  r2_id = params[:race2].to_i

  rs = RaceStats.new  
  r1_data = getAgeGroupDistribution(r1_id)
  r2_data = getAgeGroupDistribution(r2_id)
  
  #express data in percent
  if (params[:percent] == 'true')
  end
  
  r1_name = Race.get(r1_id).race_name
  r2_name = Race.get(r2_id).race_name
end







