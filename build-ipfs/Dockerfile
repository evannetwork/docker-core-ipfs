FROM ipfs/go-ipfs:v0.4.14

COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
COPY ./swarm.key /data/ipfs
RUN dos2unix /usr/local/bin/entrypoint.sh
RUN dos2unix /data/ipfs/swarm.key

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]