#!/usr/local/bin/ruby
#
# Feed Bag - A RSS Feed Archiver
#
# USAGE
#   feedbag [OPTIONS] [RSS_URL ...]
#
# ARGUMENTS
#
#   When provided, the RSS_URL will be read, added to the database and
#   scanned for next run.
#
#   When no arguments are provided, all the existing feeds in the database
#   will be scanned for new items.
#
# OPTIONS
#   -d   --db       Use the given SQLite3 database
#   -C   --clean    Destroy the database and rebuild (be careful!)
#   -l   --list     List all the feeds
#   -h   --help     Show a help message
#
# AUTHOR
#   Mark D. Reid <mark.reid@anu.edu.au>
#
# CREATED
#   2008-01-18

require 'rubygems'
require 'feed-normalizer'
require 'Sequel'
require 'optparse'

def clean_feeds ; Feed.create_table! ; end
def clean_entries ; Entry.create_table! ; end

# Wipes the entier database clean.
def clean
  clean_entries
  clean_feeds
end

# Open the given file as an SQLite database using Sequel and the models
def use(db)
  Sequel.open "sqlite:///#{db}"
  $: << File.expand_path(File.dirname(__FILE__))
  require 'models'
  
  # Build up the tables after a clean or on first run
  Feed.create_table unless Feed.table_exists?
  Entry.create_table unless Entry.table_exists?  
end

def scan(feed)
  feedin = FeedNormalizer::FeedNormalizer.parse open(feed.url)
  feedin.items.each do |item|
    if item.date_published > feed.last_checked
      puts "\t#{item.title}"
      entry = Entry.new
      entry.url = item.url
      entry.title = item.title
      entry.content = item.content
      entry.description = item.description unless item.description == item.content
      entry.time = item.date_published
      entry.feed_id = feed.id
      entry.save
    else
      print "."
    end
  end
  feed.tick
end

# Parse the command-line options and clean database if necessary
opts = OptionParser.new
opts.banner = "Usage: feedbag.rb [options] [feed_url]+"
opts.on('-d', '--db DB', 'Use feed database DB') do |db| 
  use(db) ; puts "Using #{db} for Feed DB"
end
opts.on('-l', '--list', 'List all the feeds') do
  Feed.each { |feed| puts "#{feed.id}: #{feed.name} (Checked: #{feed.last_checked}) - #{feed.entries.size}\n" }
  exit
end
opts.on('-C', '--clean', 'Wipes the current feed DB') do
  clean ; puts "Cleaned DB!"
  exit
end
opts.on_tail("-h", "--help", "Show this message") do
  puts opts
  exit
end
opts.parse!

# Add any feeds if they appear as arguments
if ARGV.empty?
  Feed.each { |feed| puts "\nScanning #{feed.name}"; scan feed }
else
  # Add RSS URLs to the databases
  ARGV.each do |arg|
    if Feed.filter {:url == arg}.empty?
      puts "Creating new feed for #{arg}"
      feed = Feed.create(:url => arg)
    else
      feed = Feed.filter {:url == arg}.first
      puts "Feed entitled '#{feed.name}' already exists for #{arg}"
    end
  end
end
