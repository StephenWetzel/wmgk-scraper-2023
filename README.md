# wmgk-scraper-2023

A rewrite of [my earlier version from 2013](https://github.com/StephenWetzel/wmgk), which was written in Perl and scraped the web page.  This one takes advantage of thier open API to put the data directly in a SQLite database.

### Database
The data is stored in a single table SQLite database named `wmgk.db`.  You can either create that database yourself with this SQL:
```
CREATE TABLE "plays" (
  "play_id" INTEGER UNIQUE,
  "artist"  TEXT,
  "title" TEXT,
  "play_dt" TEXT,
  "timestamp" INTEGER,
  "wmgk_id" INTEGER UNIQUE,
  PRIMARY KEY("play_id")
);
```

Or you can just use the provided empty SQLite database named `wmgk.db.empty` by renaming it to `wmgk.db`.

### Setup
I wrote this using Ruby 2.7.3, but it's pretty basic, so should work with many versions of Ruby.  Run `bundle install` to install the handful of gems from the gemfile.  See the above note about the database.  There are no ENV variables to set.

### Usage
There's not much to it.  Just run `ruby ./wmgk_scraper.rb` and it'll start.  First you should open it up and check out a few of the hardcoded values.  Specifically you'll see the last line:
```
# This will scrape songs, from today until 2023-06-01, 100 songs at a time
add_plays(DateTime.parse('2023-06-01'), 100)
```

You'll likely want to change those values to somethign that makes sense for you.

These should really be command line arguments you can pass in, but I'm done using this already, and am providing this code more for reference rather than an actual expectation anyone else will ever actually run this, so I'm being lazy.

### Queries
Once you have some data collected you can query it however you see fit.  Here's some example queries I found useful.

```
--plays per band over a given period
select artist as "Band", count(*), round(count(*) / 60.0 * 30.0, 2) as "Plays per 30 days" from plays
where play_dt >= '2023-06-26' and play_dt <= '2023-08-25'
--and artist like '%Joel%'
group by artist
order by 3 DESC
limit 50
```

```
--plays per song over a given period
select artist as "Band", title as "Song", count(*), round(count(*) / 60.0 * 30.0, 2) as "Plays per 30 days" from plays
where play_dt >= '2023-06-26' and play_dt <= '2023-08-25'
--and artist like '%Joel%'
group by artist, title
order by 3 DESC
limit 50
```

```
--plays per hour of day
select substr(play_dt, 11, 3) as hour, count(*) / 60.0 as "Daily plays in a given hour" from plays
where play_dt >= '2023-06-26' and play_dt <= '2023-08-25'
group by substr(play_dt, 11, 3)
```



```
-- bands where they only play 1 song by them (or just about)
select * from (
	select artist, title as top_song, count(*) as uniq_songs, sum(plays) as total_plays, max(plays) as top_song_plays, round(100.0 * max(plays) / sum(plays), 2) as pct_top_song from (
		select artist, title, count(*) as plays, round(count(*) / 60.0 * 30.0, 2) as plays_per_30_days from plays
		where play_dt >= '2023-06-26' and play_dt <= '2023-08-25'
	-- 	and artist like '%Gen%'
		group by artist, title
		order by 3 DESC
	) group by artist
	order by 4 desc, 6 desc
) where total_plays >= 30 and pct_top_song >= 75
order by artist
```
