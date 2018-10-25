#!/bin/sh
# needs to be run on the redis instance

url=http://172.16.0.2:8080/ipns/QmUQpziJZjJQfWHG7kVrJVx7CA9phZR3AjouDLP1UAU9v1
# data is a tmpfs now, so no need to keep a history in the volume
filename=/data/ipfs_blacklist.txt
#filename=/data/ipfs_blacklist-$( date +"%Y.%m.%d-%H:%M" )
#filename=/ipfs_blacklist.txt

wget $url -O $filename

test -f $filename || exit

while read hash;
  do redis-cli $hash ;
done < $filename

