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
  if [ -n "$IPFS_BOOTSTRAP_PEERS" ]; then
    for word in $IPFS_BOOTSTRAP_PEERS
    do
      ipfs bootstrap add $word
    done
  fi
  ipfs config --json Addresses.Swarm '["/ip4/0.0.0.0/tcp/4001", "/ip6/::/tcp/4001"]'
  ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["*"]'
  ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "GET", "POST", "HEAD"]'
  ipfs config --json API.HTTPHeaders.Access-Control-Allow-Credentials '["true"]'
  ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin "$IPFS_ORIGIN_ALLOW"
  if [ -n "$IPFS_STORAGE_MAX" ]; then
    ipfs config Datastore.StorageMax $IPFS_STORAGE_MAX
  else
    ipfs config Datastore.StorageMax '50GB'
  fi
fi

exec ipfs daemon --migrate=true
