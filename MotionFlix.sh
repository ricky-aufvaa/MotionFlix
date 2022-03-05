#!/bin/bash

menu="fzf --reverse"
query=$(printf "%s" "$*")
if [ $# -eq 0 ];
then echo "Make sure you pass an argument"
	exit
else
query="$(sed 's/ /\%20/g' <<<$query)"
cachedir="$HOME/testing/netflix/cache"
baseurl="https://thepiratebay.party"

curl -s $baseurl/search/$query/1/99/0 > $cachedir/tmp.html
title=$(cat $cachedir/tmp.html |grep -Eo 'title="Details.*"'|cut -d' ' -f3- >$cachedir/title.bw)

size=$(cat $cachedir/tmp.html |grep -Eo 'align="right".*<'| sed -e 's/>/ /g'|sed 's/</ /g'|sed 's/\&nbsp\;//g'|cut -d' ' -f2| grep -E 'MiB|GiB$'> $cachedir/size.bw)

seeders=$(cat $cachedir/tmp.html |grep -Eo 'align="right".*<'| sed -e 's/>/ /g'|sed 's/</ /g'|sed 's/\&nbsp\;//g'|cut -d' ' -f2| sed 's/iB/\n/g'| grep -E  'G|M$' -A 2| grep -E -v 'G|M$'|sed -e '/^$/d' -e '/^-/d' > $cachedir/seeds.bw)

LINE=$(paste -d\  $cachedir/seeds.bw $cachedir/size.bw  $cachedir/title.bw| $menu|sed 's/"//g'|cut -d' ' -f3-|sed 's/ /_/g')
magnet=$(cat $cachedir/tmp.html |grep -F $LINE -A 3| grep -Eo 'magnet:?.*Download'| sed 's/\"//g'|cut -d' ' -f1 )
peerflix -q  -a -v "$magnet"  
fi
