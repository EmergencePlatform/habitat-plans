pkg_name=php7
pkg_origin=emergence
pkg_distname=php
pkg_version=7.4.33
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=("PHP-3.01")
pkg_upstream_url=http://php.net/
pkg_description="PHP is a popular general-purpose scripting language that is especially suited to web development."
pkg_source="https://php.net/get/${pkg_distname}-${pkg_version}.tar.xz/from/this/mirror"
pkg_filename="${pkg_distname}-${pkg_version}.tar.xz"
pkg_dirname="${pkg_distname}-${pkg_version}"
pkg_shasum=924846abf93bc613815c55dd3f5809377813ac62a9ec4eb3778675b82a27b927
pkg_deps=(
  core/bash
  core/bzip2
  core/cacerts
  core/coreutils
  core/curl
  core/gcc-libs
  core/glibc
  core/icu56
  core/libfcgi
  core/libjpeg-turbo
  core/libpng
  core/libxml2
  core/libzip
  core/oniguruma
  core/openssl
  core/postgresql11-client
  core/readline
  core/sqlite
  core/zip
  core/zlib
  jarvus/ghostscript
  jarvus/imagemagick
)
pkg_build_deps=(
  core/autoconf
  core/bison
  core/gcc
  core/grep
  core/libgd
  core/make
  core/patch
  core/re2c
)
pkg_bin_dirs=(bin sbin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_interpreters=(bin/php)

ext_apcu_version=5.1.17
ext_apcu_source=https://github.com/krakjoe/apcu/archive/v${ext_apcu_version}.tar.gz
ext_apcu_filename=apcu-${ext_apcu_version}.tar.gz
ext_apcu_shasum=e6f6405ec47c2b466c968ee6bb15fc3abccb590b5fd40f579fceebeb15da6c4c
ext_apcu_dirname=apcu-${ext_apcu_version}

ext_imagick_version=3.4.4
ext_imagick_source=https://github.com/Imagick/imagick/archive/${ext_imagick_version}.tar.gz
ext_imagick_filename=imagick-${ext_imagick_version}.tar.gz
ext_imagick_shasum=8204d228ecbe5f744d625c90364808616127471581227415bca18857af981369
ext_imagick_dirname=imagick-${ext_imagick_version}

ext_xdebug_version=3.1.6
ext_xdebug_source=https://github.com/xdebug/xdebug/archive/${ext_xdebug_version}.tar.gz
ext_xdebug_filename=xdebug-${ext_xdebug_version}.tar.gz
ext_xdebug_shasum=217e05fbe43940fcbfe18e8f15e3e8ded7dd35926b0bee916782d0fffe8dcc53
ext_xdebug_dirname=xdebug-${ext_xdebug_version}

do_setup_environment() {
  set_runtime_env PHP_FPM "${pkg_prefix}/sbin/php-fpm"
  set_runtime_env SSL_CERT_FILE "$(pkg_path_for core/cacerts)/ssl/certs/cacert.pem"
}

do_download() {
  do_default_download

  download_file $ext_apcu_source $ext_apcu_filename $ext_apcu_shasum
  download_file $ext_imagick_source $ext_imagick_filename $ext_imagick_shasum
  download_file $ext_xdebug_source $ext_xdebug_filename $ext_xdebug_shasum
}

do_verify() {
  do_default_verify

  verify_file $ext_apcu_filename $ext_apcu_shasum
  verify_file $ext_imagick_filename $ext_imagick_shasum
  verify_file $ext_xdebug_filename $ext_xdebug_shasum
}

do_unpack() {
  do_default_unpack

  unpack_file $ext_apcu_filename
  mv "${HAB_CACHE_SRC_PATH}/${ext_apcu_dirname}" "${HAB_CACHE_SRC_PATH}/${pkg_dirname}/ext/apcu"
  unpack_file $ext_imagick_filename
  mv "${HAB_CACHE_SRC_PATH}/${ext_imagick_dirname}" "${HAB_CACHE_SRC_PATH}/${pkg_dirname}/ext/imagick"
  unpack_file $ext_xdebug_filename
}

do_patch() {
  return 0
}

do_build() {
  php_api_version="$(grep '#define PHP_API_VERSION' ./main/php.h | cut -d' ' -f 3)"
  set_runtime_env PHP_API_VERSION "${php_api_version}"
  php_zend_api_version="$(grep '#define ZEND_MODULE_API_NO' ./Zend/zend_modules.h | cut -d' ' -f 3)"
  set_runtime_env PHP_ZEND_API_VERSION "${php_zend_api_version}"

  set_runtime_env PHP_EXTENSION_DIR "${pkg_svc_config_install_path}/extensions-${php_zend_api_version}"
  push_runtime_env PHP_EXTENSION_SOURCES "${pkg_prefix}/lib/php/extensions/no-debug-non-zts-${php_zend_api_version}"

  do_patch

  # build_line "Running buildconf..."
  # attach
  # ./buildconf --force

  build_line "Running configure..."
  ./configure --prefix="${pkg_prefix}" \
    --with-bz2="$(pkg_path_for bzip2)" \
    --with-config-file-path="${pkg_svc_config_install_path}" \
    --with-curl \
    --with-fpm-group="${pkg_svc_group}" \
    --with-fpm-user="${pkg_svc_user}" \
    --with-gettext="$(pkg_path_for glibc)" \
    --with-imagick="$(pkg_path_for imagemagick)" \
    --with-jpeg \
    --with-libxml \
    --with-mysqli=mysqlnd \
    --with-openssl \
    --with-pdo-mysql=mysqlnd \
    --with-pdo-pgsql="$(pkg_path_for postgresql11-client)" \
    --with-readline="$(pkg_path_for readline)" \
    --with-xmlrpc \
    --with-zip \
    --with-zlib \
    --enable-apcu \
    --enable-bcmath \
    --enable-exif \
    --enable-fpm \
    --enable-gd \
    --enable-intl \
    --enable-mbstring \
    --enable-opcache

  make -j "$(nproc)"

  # xdebug can't be build until after php is installed to $pkg_prefix
}

do_install() {
  do_default_install

  # Modify PHP-FPM config so it will be able to run out of the box. To run a real
  # PHP-FPM application you would want to supply your own config with
  # --fpm-config <file>.
  mv "${pkg_prefix}/etc/php-fpm.conf.default" "${pkg_prefix}/etc/php-fpm.conf"


  # make and install xdebug extension
  export PATH="${PATH}:${pkg_prefix}/bin"
  build_line "Added php binaries to PATH: ${pkg_prefix}/bin"

  pushd "$HAB_CACHE_SRC_PATH/$ext_xdebug_dirname" > /dev/null

  build_line "Building ${ext_xdebug_dirname}"
  phpize
  ./configure --enable-xdebug
  make

  build_line "Installing ${ext_xdebug_dirname}"
  make install
  popd > /dev/null
}

do_check() {
  make test
}
