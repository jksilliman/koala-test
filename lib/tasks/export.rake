namespace :db do
  desc "Export Database to JSON"
  task :export => :environment do	  
    data = UserInterest.all.map {|user_interest| { :user_id => user_interest.user_id, :interest => user_interest.interest_id.split.each{|i| i.capitalize!}.join(' ')  } } #Normalizes capitalization
    users = {}
    data.each do |info|
      users[info[:user_id]] ||= []
      users[info[:user_id]] << info[:interest]
    end
    interest_graph = users.map {|k,v| v}
    File.open("./data.json", 'w') {|f| f.write(interest_graph.to_json) }
  end
end
