pkg_name=phpunit
pkg_origin=emergence
pkg_version="9.5"
pkg_maintainer="Chris Alfano <chris@jarv.us>"
pkg_license=("BSD-3-Clause")
pkg_deps=(
  core/coreutils
  core/composer
  core/php
)

pkg_bin_dirs=(vendor/bin)


do_build() {
  pushd "${CACHE_PATH}" > /dev/null

  COMPOSER_ALLOW_SUPERUSER=1 composer require phpunit/phpunit "^${pkg_version}"

  build_line "Fixing PHP bin scripts"
  find -L "vendor/bin" -type f -executable \
    -print \
    -exec bash -c 'sed -e "s#\#\!/usr/bin/env php#\#\!$1/bin/php#" --in-place "$(readlink -f "$2")"' _ "$(pkg_path_for php)" "{}" \;

  popd > /dev/null

}

do_install() {
  cp -r "${CACHE_PATH}/"* "${pkg_prefix}/"
}

do_strip() {
  return 0
}
