FROM ipfs/ipfs-cluster:v0.10.0

USER root
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod a+x /usr/local/bin/entrypoint.sh
RUN dos2unix /usr/local/bin/entrypoint.sh