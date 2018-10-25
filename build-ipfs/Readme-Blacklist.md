To be able to add new ipfs blacklist entries from a specific MasterNode, you have to add the blacklist_add.sh script
and the blacklist key to the ipfs_node container:

```sh
$ base64 -d blacklist.key.b64 > blacklist.key
$ sudo docker cp  blacklist.key ipfs_node:/data/ipfs/keystore/blacklist
$ sudo docker cp  blacklist_add.sh ipfs_node:/blacklist_add.sh
```

To then add new blacklist entries, add the new list file to the evan.network IPFS from any node, and then publish it
with the blacklist key. Easiest way to do this is to run the `blacklist_add.sh` via docker exec:

```sh
$ sudo docker exec -ti ipfs_node /blacklist_add.sh Qmneuer...hash
```

The next cron cycle on the `blacklist-redis` will then pull this new blacklist within the next 6 hours.
