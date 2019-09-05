pkg_name=php5
pkg_distname=php
pkg_origin=emergence
pkg_version=5.6.39
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=("PHP-3.01")
pkg_upstream_url=http://php.net/
pkg_description="PHP is a popular general-purpose scripting language that is especially suited to web development."
pkg_source="https://php.net/get/${pkg_distname}-${pkg_version}.tar.xz/from/this/mirror"
pkg_filename="${pkg_distname}-${pkg_version}.tar.xz"
pkg_dirname="${pkg_distname}-${pkg_version}"
pkg_shasum=b3db2345f50c010b01fe041b4e0f66c5aa28eb325135136f153e18da01583ad5
pkg_deps=(
  core/bzip2
  core/coreutils
  core/curl
  core/glibc
  core/icu
  core/libjpeg-turbo
  core/libpng
  core/libxml2
  core/libzip
  core/openssl
  core/postgresql11-client
  core/readline
  core/zip
  core/zlib
  core/gcc-libs
)
pkg_build_deps=(
  core/autoconf
  core/bison
  core/gcc
  core/libgd
  core/make
  core/re2c
)
pkg_bin_dirs=(bin sbin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_interpreters=(bin/php)

ext_apcu_version=4.0.11
ext_apcu_source=https://github.com/krakjoe/apcu/archive/v${ext_apcu_version}.tar.gz
ext_apcu_filename=apcu-${ext_apcu_version}.tar.gz
ext_apcu_shasum=bf1d78d4211c6fde6d29bfa71947999efe0ba0c50bdc99af3f646e080f74e3a4
ext_apcu_dirname=apcu-${ext_apcu_version}

ext_xdebug_version=2.5.5
ext_xdebug_source=https://github.com/xdebug/xdebug/archive/XDEBUG_${ext_xdebug_version//\./_}.tar.gz
ext_xdebug_filename=xdebug-XDEBUG_${ext_xdebug_version//\./_}.tar.gz
ext_xdebug_shasum=77faf3bc49ca85d9b67ae2aa9d9cc4b017544f2566e918bf90fe23d68e044244
ext_xdebug_dirname=xdebug-XDEBUG_${ext_xdebug_version//\./_}

do_download() {
  do_default_download

  download_file $ext_apcu_source $ext_apcu_filename $ext_apcu_shasum
  download_file $ext_xdebug_source $ext_xdebug_filename $ext_xdebug_shasum
}

do_verify() {
  do_default_verify

  verify_file $ext_apcu_filename $ext_apcu_shasum
  verify_file $ext_xdebug_filename $ext_xdebug_shasum
}

do_unpack() {
  do_default_unpack

  unpack_file $ext_apcu_filename
  mv "$HAB_CACHE_SRC_PATH/$ext_apcu_dirname" "$HAB_CACHE_SRC_PATH/$pkg_dirname/ext/apcu"
  unpack_file $ext_xdebug_filename
}

do_build() {
  rm aclocal.m4
  ./buildconf --force

  ./configure --prefix="${pkg_prefix}" \
    --with-config-file-path="${pkg_svc_config_install_path}" \
    --enable-exif \
    --enable-fpm \
    --enable-apcu \
    --with-fpm-user="${pkg_svc_user}" \
    --with-fpm-group="${pkg_svc_group}" \
    --enable-mbstring \
    --enable-opcache \
    --with-mysqli=mysqlnd \
    --with-pdo-mysql=mysqlnd \
    --with-pdo-pgsql="$(pkg_path_for postgresql11-client)" \
    --with-readline="$(pkg_path_for readline)" \
    --with-curl="$(pkg_path_for curl)" \
    --with-gd \
    --with-jpeg-dir="$(pkg_path_for libjpeg-turbo)" \
    --with-libxml-dir="$(pkg_path_for libxml2)" \
    --with-openssl="$(pkg_path_for openssl)" \
    --with-png-dir="$(pkg_path_for libpng)" \
    --with-xmlrpc \
    --with-zlib="$(pkg_path_for zlib)" \
    --enable-zip \
    --with-libzip="$(pkg_path_for libzip)" \
    --with-bz2="$(pkg_path_for bzip2)" \
    --with-gettext="$(pkg_path_for glibc)" \
    --enable-intl

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
