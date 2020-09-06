FROM klakegg/hugo:0.74.3-ext-alpine-onbuild AS hugo
FROM nginx:1.19.2-alpine as nginx

COPY --from=hugo /target /usr/share/nginx/html

EXPOSE 80
EXPOSE 443
