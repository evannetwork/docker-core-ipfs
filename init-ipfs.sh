#!/bin/sh
set -ex
ipfs bootstrap rm all
ipfs bootstrap add "$IPFS_BOOTSTRAP_PEER"
ipfs config Datastore.StorageMax $IPFS_STORAGE_MAX
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["*"]'
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "GET", "POST", "HEAD"]'
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Credentials '["true"]'
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["*","http://localhost:3000","https://ipfs.test.evan.network","https://dashboard.test.evan.network","https://ipfs.evan.network","https://dashboard.evan.network"]'
