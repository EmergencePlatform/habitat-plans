pkg_name=nginx
pkg_origin=emergence
pkg_version=1.15.6
pkg_description="NGINX web server."
pkg_maintainer="Chris Alfano <chris@jarv.us>"
pkg_license=('BSD-2-Clause')
pkg_source="https://nginx.org/download/nginx-${pkg_version}.tar.gz"
pkg_upstream_url=https://nginx.org/
pkg_shasum=a3d8c67c2035808c7c0d475fffe263db8c353b11521aa7ade468b780ed826cc6
pkg_deps=(core/glibc core/libedit core/ncurses core/zlib core/bzip2 core/openssl core/pcre core/curl)
pkg_build_deps=(core/gcc core/make core/coreutils)
pkg_lib_dirs=(lib)
pkg_bin_dirs=(sbin)
pkg_include_dirs=(include)
pkg_svc_run="nginx"
pkg_svc_user="root"
pkg_exports=(
  [port]=http.listen.port
  [status_path]=default_server.stub_status_path
)
pkg_exposes=(port)
pkg_binds_optional=(
  [backend]="port"
)

do_build() {
  ./configure --prefix="$pkg_prefix" \
    --conf-path="$pkg_svc_config_path/nginx.conf" \
    --sbin-path="$pkg_prefix/bin/nginx" \
    --pid-path="$pkg_svc_var_path/nginx.pid" \
    --lock-path="$pkg_svc_var_path/nginx.lock" \
    --user=hab \
    --group=hab \
    --http-log-path=/dev/stdout \
    --error-log-path=stderr \
    --http-client-body-temp-path="$pkg_svc_var_path/client-body" \
    --http-proxy-temp-path="$pkg_svc_var_path/proxy" \
    --http-fastcgi-temp-path="$pkg_svc_var_path/fastcgi" \
    --http-scgi-temp-path="$pkg_svc_var_path/scgi" \
    --http-uwsgi-temp-path="$pkg_svc_var_path/uwsgi" \
    --with-ipv6 \
    --with-pcre \
    --with-pcre-jit \
    --with-file-aio \
    --with-stream=dynamic \
    --with-stream_ssl_module \
    --with-mail=dynamic \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_realip_module \
    --with-http_v2_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_addition_module \
    --with-http_degradation_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_secure_link_module \
    --with-http_sub_module \
    --with-http_slice_module \
    --with-cc-opt="$CFLAGS" \
    --with-ld-opt="$LDFLAGS"

  make
}

do_install() {
  make install
  mkdir -p "$pkg_prefix/sbin"
  cp "$HAB_CACHE_SRC_PATH/$pkg_dirname/objs/nginx" "$pkg_prefix/sbin"
  cp -rv "$PLAN_CONTEXT/default-web" "$pkg_prefix/"
}
