FROM ipfs/go-ipfs:v0.4.17

COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
COPY ./swarm.key /data/ipfs
RUN dos2unix /usr/local/bin/entrypoint.sh
RUN chmod a+x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]