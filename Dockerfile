# 通用Dockerfile，支持alpine和debian，参数由流水线传递
ARG NGINX_IMAGE
ARG NGINX_VERSION
ARG INSTALL_PKGS

FROM ${NGINX_IMAGE} AS builder

WORKDIR /root/

RUN set -e \
    && eval $INSTALL_PKGS \
    && wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && tar zxf nginx-${NGINX_VERSION}.tar.gz \
    && git clone https://github.com/google/ngx_brotli.git \
    && cd ngx_brotli \
    && git submodule update --init --recursive \
    && cd ../nginx-${NGINX_VERSION} \
    && CONFIG=`nginx -V 2>&1 | tr '\n' ' ' | sed 's/^.* configure arguments: //g'` \
    && echo "./configure --add-dynamic-module=../ngx_brotli $CONFIG" > configure.sh \
    && chmod +x configure.sh \
    && ./configure.sh \
    && make modules \

FROM ${NGINX_IMAGE}

ENV TIME_ZONE=Asia/Shanghai

RUN ln -snf /usr/share/zoneinfo/$TIME_ZONE /etc/localtime && echo $TIME_ZONE > /etc/timezone \
    && sed -i '1iload_module /usr/lib/nginx/modules/ngx_http_brotli_filter_module.so;' /etc/nginx/nginx.conf \
    && sed -i '2iload_module /usr/lib/nginx/modules/ngx_http_brotli_static_module.so;' /etc/nginx/nginx.conf

COPY --from=builder /root/nginx-${NGINX_VERSION}/objs/ngx_http_brotli_filter_module.so /usr/lib/nginx/modules/
COPY --from=builder /root/nginx-${NGINX_VERSION}/objs/ngx_http_brotli_static_module.so /usr/lib/nginx/modules/

