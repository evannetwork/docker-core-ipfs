FROM openresty/openresty:alpine

COPY ./ngx_ipfs_blacklist.lua /etc/nginx/ngx_ipfs_blacklist.lua
COPY ./ngx_ipfs_add_pin_validator.lua /etc/nginx/ngx_ipfs_add_pin_validator.lua
COPY ./nginx.conf.template /etc/nginx/nginx.conf.template

RUN dos2unix /etc/nginx/nginx.conf.template
RUN apk update
# needed for envsubst
RUN apk add gettext
# needed for access script
RUN apk add  lua5.1-redis