FROM nginx:stable AS builder

ARG NGINX_VERSION

WORKDIR /root/

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    libpcre3-dev \
    libssl-dev \
    zlib1g-dev \
    libbrotli-dev \
    wget \
    && wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && tar zxf nginx-${NGINX_VERSION}.tar.gz \
    && git clone https://github.com/google/ngx_brotli.git \
    && cd ngx_brotli \
    && git submodule update --init --recursive \
    && cd ../nginx-${NGINX_VERSION} \
    && ./configure \
    --add-dynamic-module=../ngx_brotli \
    $(nginx -V 2>&1 | tail -1 | sed -e 's/configure arguments: //') \
    && make modules

FROM nginx:stable

ENV TIME_ZONE=Asia/Shanghai

RUN ln -snf /usr/share/zoneinfo/$TIME_ZONE /etc/localtime && echo $TIME_ZONE > /etc/timezone

COPY --from=builder /root/nginx-${NGINX_VERSION}/objs/ngx_http_brotli_filter_module.so /usr/lib/nginx/modules/
COPY --from=builder /root/nginx-${NGINX_VERSION}/objs/ngx_http_brotli_static_module.so /usr/lib/nginx/modules/
