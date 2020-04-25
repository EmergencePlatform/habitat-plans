source "${PLAN_CONTEXT}/../php7/plan.sh"

# configure for version 5.6
pkg_name=php5
pkg_distname=php
pkg_version=5.6.40
pkg_source="https://php.net/get/${pkg_distname}-${pkg_version}.tar.xz/from/this/mirror"
pkg_filename="${pkg_distname}-${pkg_version}.tar.xz"
pkg_dirname="${pkg_distname}-${pkg_version}"
pkg_shasum=1369a51eee3995d7fbd1c5342e5cc917760e276d561595b6052b21ace2656d1c

# configure APCu version compatible with 5.6
ext_apcu_version=4.0.11
ext_apcu_source=https://github.com/krakjoe/apcu/archive/v${ext_apcu_version}.tar.gz
ext_apcu_filename=apcu-${ext_apcu_version}.tar.gz
ext_apcu_shasum=bf1d78d4211c6fde6d29bfa71947999efe0ba0c50bdc99af3f646e080f74e3a4
ext_apcu_dirname=apcu-${ext_apcu_version}

# configure xdebug version compatible with 5.6
ext_xdebug_version=2.5.5
ext_xdebug_source=https://github.com/xdebug/xdebug/archive/XDEBUG_${ext_xdebug_version//\./_}.tar.gz
ext_xdebug_filename=xdebug-XDEBUG_${ext_xdebug_version//\./_}.tar.gz
ext_xdebug_shasum=77faf3bc49ca85d9b67ae2aa9d9cc4b017544f2566e918bf90fe23d68e044244
ext_xdebug_dirname=xdebug-XDEBUG_${ext_xdebug_version//\./_}


do_patch() {
  patch -p0 -i "${PLAN_CONTEXT}/php67583.patch"
}

# copy config/hooks from php7
do_build_config() {
  do_default_build_config

  build_line "Merging php7 config"
  cp -nrvL "${PLAN_CONTEXT}/../php7"/{config_install,config,hooks,default.toml} "${pkg_prefix}/"
}
