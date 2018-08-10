#!/bin/sh
cd build-cluster; docker build -t evannetwork/ipfs-cluster . ; cd ..
cd build-ipfs; docker build -t evannetwork/go-ipfs . ; cd ..
cd build-nginx-ipfs; docker build -t evannetwork/nginx-ipfs  . ; cd ..
cd build-blacklist-redis ;docker build -t evannetwork/blacklist-redis . ; cd ..
