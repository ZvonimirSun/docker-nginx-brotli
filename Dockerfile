# 通用Dockerfile，支持alpine和debian，参数由流水线传递
ARG NGINX_IMAGE
ARG INSTALL_PKGS

FROM $NGINX_IMAGE AS builder

ARG INSTALL_PKGS

WORKDIR /root/

RUN set -ex \
    && sh -c "${INSTALL_PKGS}" \
    && wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && tar zxf nginx-${NGINX_VERSION}.tar.gz \
    && git clone https://github.com/google/ngx_brotli.git \
    && cd ngx_brotli \
    && git submodule update --init --recursive \
    && cd .. \
    && git clone https://github.com/vision5/ngx_devel_kit.git \
    && git clone https://github.com/openresty/lua-nginx-module.git \
    && git clone https://luajit.org/git/luajit.git \
    && cd luajit \
    && make && make install PREFIX=/usr/local/luajit \
    && export LUAJIT_LIB=/usr/local/luajit/lib \
    && export LUAJIT_INC=/usr/local/luajit/include/luajit-2.1 \
    && cd ../nginx-${NGINX_VERSION} \
    && CONFIG=`nginx -V 2>&1 | tr '\n' ' ' | sed 's/^.* configure arguments: //g'` \
    && echo "./configure --add-dynamic-module=../ngx_brotli --add-dynamic-module=../ngx_devel_kit --add-dynamic-module=../lua-nginx-module --with-ld-opt='-Wl,-rpath,/usr/local/luajit/lib' $CONFIG" > configure.sh \
    && chmod +x configure.sh \
    && ./configure.sh \
    && make modules

FROM $NGINX_IMAGE AS final

ENV TIME_ZONE=Asia/Shanghai

RUN ln -snf /usr/share/zoneinfo/$TIME_ZONE /etc/localtime && echo $TIME_ZONE > /etc/timezone \
    && sed -i '1iload_module /usr/lib/nginx/modules/ngx_http_brotli_filter_module.so;' /etc/nginx/nginx.conf \
    && sed -i '2iload_module /usr/lib/nginx/modules/ngx_http_brotli_static_module.so;' /etc/nginx/nginx.conf \
    && sed -i '3iload_module /usr/lib/nginx/modules/ndk_http_module.so;' /etc/nginx/nginx.conf \
    && sed -i '4iload_module /usr/lib/nginx/modules/ngx_http_lua_module.so;' /etc/nginx/nginx.conf

COPY --from=builder /root/nginx-${NGINX_VERSION}/objs/ngx_http_brotli_filter_module.so /usr/lib/nginx/modules/
COPY --from=builder /root/nginx-${NGINX_VERSION}/objs/ngx_http_brotli_static_module.so /usr/lib/nginx/modules/
COPY --from=builder /root/nginx-${NGINX_VERSION}/objs/ndk_http_module.so /usr/lib/nginx/modules/
COPY --from=builder /root/nginx-${NGINX_VERSION}/objs/ngx_http_lua_module.so /usr/lib/nginx/modules/
COPY --from=builder /usr/local/luajit /usr/local/luajit
