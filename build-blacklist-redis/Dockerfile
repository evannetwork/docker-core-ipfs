FROM redis:4-alpine

COPY ./blacklist_start.sh /blacklist_start.sh
COPY ./blacklist_refresh.sh /blacklist_refresh.sh
RUN echo "17 */6 * * * /blacklist_refresh.sh" >> /etc/crontabs/root
RUN chmod a+x /blacklist_start.sh /blacklist_refresh.sh
CMD /blacklist_start.sh