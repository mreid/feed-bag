Feed Bag - A RSS Feed Archiver
==============================
[Mark D. Reid](mailto://mark.reid@anu.edu.au)

This is a simple ruby script that will archive RSS feeds to an SQLite database.

You can find more information, installation and usage instructions at the
[Feed Bag Home Page][].

Dependencies
------------
* [Feed Normalizer][]
* [Sequel][]


Usage
-----

    feedbag.rb [OPTIONS] [RSS_URL ...]

Arguments
---------
When provided, the RSS_URL will be read, added to the database and scanned for 
next run.

When no arguments are provided, all the existing feeds in the database will be 
scanned for new items.

Options
-------
    -d   --db       Use the given SQLite3 database
    -C   --clean    Destroy the database and rebuild (be careful!)
    -l   --list     List all the feeds
    -h   --help     Show a help message

[Feed Bag Home Page]: http://users.rsise.anu.edu.au/~mreid/code/feed_bag.html
[Feed Normalizer]: http://rubyforge.org/projects/feed-normalizer/
[Sequel]: http://sequel.rubyforge.org/