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
