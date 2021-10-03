pkg_name=php7-mssql
pkg_origin=emergence
pkg_version=5.9.0
pkg_maintainer="Jarvus Innovations <hello@jarv.us>"
pkg_license=("MIT")
pkg_upstream_url="https://github.com/microsoft/msphpsql"
pkg_description="Microsoft Drivers for PHP for SQL Server"
pkg_source="https://github.com/microsoft/msphpsql/archive/v${pkg_version}.tar.gz"
pkg_dirname="msphpsql-${pkg_version}"
pkg_shasum="fe960c4c32c83cd98c84fe85c5cdcb145ed0679ee36a3ab6f16132249a4c0d61"
pkg_deps=(
  core/gcc-libs
  core/libtool
  core/msodbcsql17
  core/unixodbc
  emergence/php7
)
pkg_build_deps=(
  core/autoconf
  core/binutils
  core/diffutils
  core/gawk
  core/gcc
  core/grep
  core/make
  core/re2c
  core/sed
)

do_setup_environment() {
  set_runtime_env ODBCSYSINI "${pkg_svc_config_install_path}"
}

do_before() {
  # append PHP_EXTENSION_SOURCES after env is initially built
  push_runtime_env PHP_EXTENSION_SOURCES "${pkg_prefix}/extensions-${PHP_ZEND_API_VERSION}"
}

do_build() {
  pushd "source" > /dev/null
  bash packagize.sh

  pushd "sqlsrv" > /dev/null
  phpize
  ./configure
  make
  popd > /dev/null

  pushd "pdo_sqlsrv" > /dev/null
  phpize
  ./configure
  make
  popd > /dev/null

  popd > /dev/null
}

do_install() {
  extensions_dir="${pkg_prefix}/extensions-${PHP_ZEND_API_VERSION}"
  mkdir "${extensions_dir}"
  cp -v source/*/modules/*.so "${extensions_dir}"
}
