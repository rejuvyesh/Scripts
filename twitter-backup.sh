#!/bin/zsh

# Created by rejuvyesh <rejuvyesh@gmail.com>

source ~/.zsh/zsh_env

DAY=$(date +'%Y-%m-%d')
DIR="/home/rejuvyesh/archive/twitter/$DAY/"

mkdir -p $DIR

echo "Backing up tweets..."
/home/rejuvyesh/.bundle/bin/t timeline @rejuvyesh --csv --number 3000 > $DIR/tweets.csv

echo "Backing up retweets..."
/home/rejuvyesh/.bundle/bin/t retweets --csv --number 3000 > $DIR/retweets.csv
echo "Backing up favorites..."
/home/rejuvyesh/.bundle/bin/t favorites --csv --number 3000 > $DIR/favorites.csv

echo "Backing up DM received..."
/home/rejuvyesh/.bundle/bin/t direct_messages --csv --number 3000 > $DIR/dm_received.csv
echo "Backing up DM sent..."
/home/rejuvyesh/.bundle/bin/t direct_messages_sent --csv --number 3000 > $DIR/dm_sent.csv

echo "Backing up followings..."
/home/rejuvyesh/.bundle/bin/t followings --csv > $DIR/followings.csv
echo "Backing up followers..."
/home/rejuvyesh/.bundle/bin/t followers --csv > $DIR/followers.csv

echo "Compressing backups..."
xz -f -9 $DIR/*.csv
