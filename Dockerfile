# 通用Dockerfile，支持alpine和debian，参数由流水线传递
ARG NGINX_IMAGE
ARG INSTALL_PKGS

FROM $NGINX_IMAGE AS builder

ARG INSTALL_PKGS

WORKDIR /root/

RUN set -ex \
    && sh -c "${INSTALL_PKGS}" \
    && NJS_VERSION="$(curl -s https://api.github.com/repos/nginx/njs/releases/latest | jq -r '.tag_name')" \
    && curl -fsSL -o nginx-${NGINX_VERSION}.tar.gz http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && tar zxf nginx-${NGINX_VERSION}.tar.gz \
    && git clone https://github.com/google/ngx_brotli.git \
    && cd ngx_brotli \
    && git submodule update --init --recursive \
    && cd .. \
    && git clone --depth 1 --branch ${NJS_VERSION} https://github.com/nginx/njs.git \
    && cd nginx-${NGINX_VERSION} \
    && ./configure --with-compat --with-stream \
        --add-dynamic-module=../ngx_brotli \
        --add-dynamic-module=../njs/nginx \
    && make modules

FROM $NGINX_IMAGE AS final

ENV TIME_ZONE=Asia/Shanghai

RUN ln -snf /usr/share/zoneinfo/$TIME_ZONE /etc/localtime && echo $TIME_ZONE > /etc/timezone \
    && sed -i '1iload_module /usr/lib/nginx/modules/ngx_http_brotli_filter_module.so;' /etc/nginx/nginx.conf \
    && sed -i '2iload_module /usr/lib/nginx/modules/ngx_http_brotli_static_module.so;' /etc/nginx/nginx.conf \
    && sed -i '3iload_module /usr/lib/nginx/modules/ngx_http_js_module.so;' /etc/nginx/nginx.conf \
    && sed -i '4iload_module /usr/lib/nginx/modules/ngx_stream_js_module.so;' /etc/nginx/nginx.conf

COPY --from=builder /root/nginx-${NGINX_VERSION}/objs/ngx_http_brotli_filter_module.so /usr/lib/nginx/modules/
COPY --from=builder /root/nginx-${NGINX_VERSION}/objs/ngx_http_brotli_static_module.so /usr/lib/nginx/modules/
COPY --from=builder /root/nginx-${NGINX_VERSION}/objs/ngx_http_js_module.so /usr/lib/nginx/modules/
COPY --from=builder /root/nginx-${NGINX_VERSION}/objs/ngx_stream_js_module.so /usr/lib/nginx/modules/
