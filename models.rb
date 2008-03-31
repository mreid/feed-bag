# Feed Bag - A RSS Feed Archiver
#
# AUTHOR
#   Mark D. Reid <mark.reid@anu.edu.au>
#
# CREATED
#   2008-01-18

# NOTE: Sequel must have already been opened with a DB before these models are. 

require 'rubygems'
require 'sequel'

# Feeds URLs are stored here along with when they were last checked. 
class Feed < Sequel::Model(:feeds)
  set_schema do
    primary_key   :id
    text          :name
    text          :url
    time          :last_checked
    time          :created
  end
  
  after_create do
    feed = FeedNormalizer::FeedNormalizer.parse open(url)
    set(:name => feed.title, :created => Time.now, :last_checked => Time.parse("Jan 1, 1970"))
    puts "\tThe new feed is called '#{name}'"
  end
  
  # Returns all the entries for this feed
  def entries; Entry.filter(:feed_id => pk); end
  
  # Gets the most recent timestamp for any entry from this feed
  def last_time
    last = entries.order(:time.desc).first
    if last.nil?
      last_checked
    else
      last.time
    end
  end

  # Updates this feed so its last_checked is the most recent entry's timestamp
  def tick
    set(:last_checked => last_time)    
  end
end

# An Entry is a single element of a Feed.
class Entry < Sequel::Model(:entries)
  set_schema do
    primary_key   :id
    text          :url
    text          :title
    text          :content
    text          :description
    time          :time

    foreign_key   :feed_id, :table => :feeds
    index         :url
  end
end
