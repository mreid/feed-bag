#!/bin/bash
if [ -z "$1" ]
then
	echo "Usage: tally.sh FEED_DB"
elif [ -f "$1" ]
then
	sqlite3 -column $1 "select count(*),name from entries, feeds where entries.feed_id = feeds.id group by feed_id;"
else
	echo "Cannot open $1"
fi