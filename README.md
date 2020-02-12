# evan.network IPFS node

The storage servers are used to store SmartContract payloads. The evan.network storage concept is based on the IPFS architecture. At least 2 IPFS Nodes should be provided for each AuthorItynode. The storage servers connect to a distributed network via P2P and ensure the replication and storage of the payload. The nodes are added to DNS load balancing, which distributes users when accessing the IPFS.

## Requirements

The technical requirements to the installed server are :
AWS:
 - T2.xlarge /T2.large Instance
 - Min. 5000GB EBS storage

Azure:
 - Standard_D4_v3 / Standard_D2_v3
 - Min 5000GB Standard storage

OnPremise:
 - 2 Xeon CPU's
 - 16GB RAM
 - 5000GB HDD storage

DigitalOcean:
- Standard droplet with
- 8GB RAM, 4 vCPU, 160gb SSD
- Min. 1000gb additional block storage

Open Ports:
 - 80 - HTTP
 - 443 - HTTPS
 - 4001 - IPFS Sync
 - 9096 - IPFS Cluster Sync

- 1 fixed IP public address

To start the ipfs node you must have installed [docker](https://www.docker.com/get-docker) and [docker-compose](https://docs.docker.com/compose/install/) on your Server

## Configuration

Nothing to configure

## Starting

To start your ipfs node, you have to simply run "docker-compose up -d" in the directory.

## Logging

To access the log file from the authoritynode, you can use the command "docker logs -f --tail 1000 RUNNING_CONTAINER_NAME" to get the last 1000 log lines from the container. The RUNNING_CONTAINER_NAME can be replaced with the following names:

- ipfs_cluster (IPFS Cluster)
- ipfs_node (IPFS Node)
- nginx_ipfs (NGINX reverse proxy)

## Troubleshooting

If any of the nodes behave wrong, you can restart the container with the command "docker restart RUNNING_CONTAINER_NAME"

Please reach out our support team with the last logs of your container, to check if there's anything wrong.
