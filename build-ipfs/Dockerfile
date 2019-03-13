FROM ipfs/go-ipfs:v0.4.19

COPY ./entrypoint.sh /home/ipfs/entrypoint.sh
USER root
RUN dos2unix /home/ipfs/entrypoint.sh
RUN chmod a+x /home/ipfs/entrypoint.sh

ENTRYPOINT ["/sbin/tini", "--", "/home/ipfs/entrypoint.sh"]