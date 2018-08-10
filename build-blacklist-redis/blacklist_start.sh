#!/bin/sh
# needs to be run on the redis instance

redis-server &

sleep 10

/blacklist_refresh.sh

exec crond -f -d 8



