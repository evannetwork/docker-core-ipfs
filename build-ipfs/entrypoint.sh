#!/bin/sh

set -e
user=ipfs

if [ -n "$DOCKER_DEBUG" ]; then
   set -x
fi

# Test whether the mounted directory is writable for us
if [ ! -w "$IPFS_PATH" 2>/dev/null ]; then
  echo "error: $repo is not writable for user $user (uid=$(id -u $user))"
  exit 1
fi

if [ -e "$IPFS_PATH/config" ]; then
  echo "Found IPFS fs-repo at $IPFS_PATH"
else
  ipfs init --profile=server

  ipfs config Addresses.API /ip4/0.0.0.0/tcp/5001

  ipfs config Addresses.Gateway /ip4/0.0.0.0/tcp/8080

  ipfs bootstrap rm --all
  ipfs bootstrap add /ip4/18.196.143.168/tcp/4001/ipfs/QmPQCUHUqWTWyktBEHjTwiWpEKrsZa8RYtddz9ATEyJqDK
  ipfs bootstrap add /ip4/18.196.211.140/tcp/4001/ipfs/Qmambifh7mAj4QVKrRE9mHXMAHLcuCuUYXvArRbim13Azv

  ipfs config --json Addresses.Swarm '["/ip4/0.0.0.0/tcp/4001", "/ip6/::/tcp/4001"]'
  ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["*"]'  
  ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "GET", "POST", "HEAD"]'
  ipfs config --json API.HTTPHeaders.Access-Control-Allow-Credentials '["true"]'
  ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["http://localhost:3000","https://ipfs.evan.network","https://dashboard.evan.network"]'
fi

exec ipfs daemon --migrate=true
