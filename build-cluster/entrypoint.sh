#!/bin/sh

set -e
user=ipfs

if [ -n "$DOCKER_DEBUG" ]; then
   set -x
fi

if [ `id -u` -eq 0 ]; then
    echo "Changing user to $user"
    # ensure directories are writable
    su-exec "$user" test -w "${IPFS_CLUSTER_PATH}" || chown -R -- "$user" "${IPFS_CLUSTER_PATH}"
    exec su-exec "$user" "$0" $@
fi

# Only ipfs user can get here
ipfs-cluster-service --version

if [ -e "${IPFS_CLUSTER_PATH}/service.json" ]; then
    echo "Found IPFS cluster configuration at ${IPFS_CLUSTER_PATH}"
else
    ipfs-cluster-service init
    sed -i 's;127\.0\.0\.1/tcp/9094;0.0.0.0/tcp/9094;' "${IPFS_CLUSTER_PATH}/service.json"
    sed -i 's;127\.0\.0\.1/tcp/9095;0.0.0.0/tcp/9095;' "${IPFS_CLUSTER_PATH}/service.json"

    if [ -n "$IPFS_API" ]; then
        sed -i "s;/ip4/127\.0\.0\.1/tcp/5001;$IPFS_API;" "${IPFS_CLUSTER_PATH}/service.json"
    fi
    if [ -n "$IPFS_CLUSTER_SECRET" ]; then
        sed -i 's/^\(\s*"secret":\s*"\)[^"]*/\1'$IPFS_CLUSTER_SECRET'/' "${IPFS_CLUSTER_PATH}/service.json"
    fi
    if [ -n "$IPFS_CLUSTER_BOOTSTRAP_NODE" ]; then
        sed -i -e "s;\"bootstrap\": \[\];\"bootstrap\": [\"${IPFS_CLUSTER_BOOTSTRAP_NODE}\"];" "${IPFS_CLUSTER_PATH}/service.json"
    fi
    if [ -n "$IPFS_CLUSTER_DISABLE_LEAVE" ]; then
        sed -i 's/^\(\s*"leave_on_shutdown":\s*\)\w*/\1false/' "${IPFS_CLUSTER_PATH}/service.json"
    else
        sed -i 's/^\(\s*"leave_on_shutdown":\s*\)\w*/\1true/' "${IPFS_CLUSTER_PATH}/service.json"
    fi
    # change replication factors
    sed -i '/replication_factor_min/c\    \"replication_factor_min\": 1,' "${IPFS_CLUSTER_PATH}/service.json"
    sed -i '/replication_factor_max/c\    \"replication_factor_max\": 5,' "${IPFS_CLUSTER_PATH}/service.json"
    # change state sync intervals to 1h
    sed -i '/state_sync_interval/c\    \"state_sync_interval\": \"60m0s\",' "${IPFS_CLUSTER_PATH}/service.json"
    sed -i '/ipfs_sync_interval/c\    \"ipfs_sync_interval\": \"60m0s\",' "${IPFS_CLUSTER_PATH}/service.json"
    # change monitor ping interval to 1m
    sed -i '/monitor_ping_interval/c\    \"monitor_ping_interval\": \"1m0s\",' "${IPFS_CLUSTER_PATH}/service.json"
    # disable repinning
    sed -i '/disable_repinning/c\    \"disable_repinning\": true' "${IPFS_CLUSTER_PATH}/service.json"
    # increase wait for leader timeout to 1m
    sed -i '/wait_for_leader_timeout/c\      \"wait_for_leader_timeout\": \"1m0s\",' "${IPFS_CLUSTER_PATH}/service.json"

fi

exec ipfs-cluster-service $@