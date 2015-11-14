FROM alpine:3.2

ENV DEPS "make gcc musl-dev pcre-dev openssl-dev zlib-dev ncurses-dev readline-dev wget perl"

RUN printf "####### Updating Alpine ########"

RUN apk update
RUN apk add $DEPS

RUN printf "###### Grabbing Openresty ######"

RUN mkdir openresty
RUN wget --no-check-certificate -O openresty.tgz https://openresty.org/download/ngx_openresty-1.9.3.1.tar.gz
RUN tar -zxf openresty.tgz

RUN printf "##### Installing Openresty #####"

RUN NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
    cd ngx_* && \
    ./configure \
    --with-luajit \
    --with-pcre-jit \
    --with-ipv6 \
    --with-http_ssl_module \
    -j${NPROC}  && \
    make -j${NPROC} && \
    make install

RUN printf "##### Removing build deps #####"

RUN apk del make gcc musl-dev pcre-dev openssl-dev zlib-dev ncurses-dev readline-dev curl perl

RUN apk add libpcrecpp libpcre16 libpcre32 openssl libssl1.0 pcre libgcc libstdc++

RUN rm -rf /var/cache/apk/* && rm -rf /root/openresty* && rm -rf /root/ngx*

RUN ln -s /usr/local/openresty/nginx/sbin/nginx /usr/local/bin

WORKDIR /usr/local/openresty/nginx

ONBUILD RUN rm -rf conf/* html/*
ONBUILD COPY nginx /usr/local/openresty/nginx

CMD ["nginx", "-g", "daemon off; error_log /dev/stderr info;"]