# frozen_string_literal: true

# Create an empty SQLite database with a single table:
# CREATE TABLE "plays" (
#   "play_id" INTEGER UNIQUE,
#   "artist"  TEXT,
#   "title" TEXT,
#   "play_dt" TEXT,
#   "timestamp" INTEGER,
#   "wmgk_id" INTEGER UNIQUE,
#   PRIMARY KEY("play_id")
# );

# An empty database is provided in the repo named wmgk.db.empty, rename that to just wmgk.db.

require 'date'
require 'json'
require 'net/http'
require 'cgi'
require 'sequel'
require 'csv'

DB = Sequel.connect('sqlite://wmgk.db')
DB.integer_booleans = true

class Play < Sequel::Model
end

def get_plays(offset: 0, limit: 100)
  # https://nowplaying.bbgi.com/WMGKFM/list?limit=10&offset=0
  url = "https://nowplaying.bbgi.com/WMGKFM/list?limit=#{limit}&offset=#{offset}"
  # puts url
  uri = URI(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  plays_json = JSON.parse(response.body, symbolize_names: true) 
  return plays_json
end

def clean_up_string(string)
  string = CGI.unescapeHTML(string)
  return string if string.scan(/[a-z]/).length > 0

  return string.gsub(/[a-zA-Z0-9']+/) { |w| w.capitalize }
end

def filter_artist?(artist)
  return ["Andre   pk", "Andre   th", "Andre' Gardner", "Steven Van Zandt"].include? artist
end

def add_plays(stop_dt, limit = 100)
  iteration = 0 # this should be 0 normally, set it higher if you are trying to manually resume a previous scrape
  earliest_play_dt = DateTime.now
  until earliest_play_dt.to_datetime < stop_dt.to_datetime do
    offset = iteration * limit
    plays_json = get_plays(offset: offset, limit: limit)
    plays_json.each do |play_json|
      next if filter_artist?(clean_up_string(play_json[:artist]))
      play_dt = Time.at(play_json[:timestamp])
      DB[:plays].insert_conflict.insert(
        artist: clean_up_string(play_json[:artist]),
        title: clean_up_string(play_json[:title]),
        play_dt: play_dt.to_s,
        timestamp: play_json[:timestamp],
        wmgk_id: play_json[:id]
      )
      earliest_play_dt = play_dt if play_dt.to_datetime < earliest_play_dt.to_datetime
    end
    # break if iteration >= 10
    puts "iteration: #{iteration}, earliest_play_dt: #{earliest_play_dt}"
    sleep 0.1
    iteration += 1
  end
end

# This will scrape songs, from today until 2023-06-01, 100 songs at a time
add_plays(DateTime.parse('2023-06-01'), 100)

