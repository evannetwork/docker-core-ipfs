#!/bin/sh
# needs to be run on the redis instance

new_blacklist=/ipfs/%1

ipfs pin add $new_blacklist
ipfs name publish --key blacklist $new_blacklist
ipfs pin add -r /ipns/QmUQpziJZjJQfWHG7kVrJVx7CA9phZR3AjouDLP1UAU9v1


