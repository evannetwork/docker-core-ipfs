FROM nginx:1.13.8-alpine

COPY ./nginx.template.conf /etc/nginx/nginx.conf.template

RUN dos2unix /etc/nginx/nginx.conf.template