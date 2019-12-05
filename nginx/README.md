# emergence/nginx

This is a customized build of nginx, specialized for being a frontend for PHP/fastcgi applications.

It is kept as close as possible to core/nginx so that improvements there can be continuously merged in.

## Departures from core/nginx

- Origin is explicitly set to `emergence`
- `worker_processes` config default changed to `"auto"`
- `worker_rlimit_nofile` config added and defaulted to `8192`
- `http.access_log` config added and defaulted to none
- Removes `redirector` config
- keepalive enabled
- Adds default static site to display when no backend is bound

## Additional features

- `snippet` config at the `events`, `http`, `upstream`, `default_server`, and `servers.*` level for injecting arbitrary nginx line(s).
- Optional `backend` bind defines upstream named `backend` for any/all members of optional bind
- `ssl_certificate` and `ssl_certificate_key` configs can be set to file paths to enable SSL under `default_server` or `servers.*`
- `stub_status_path` can be configured on `default_server` and is used for `health-check` hook
- `log_ignore_locations` can be configured on `default_server` to an array of paths to ignore in logs (defaults to `favicon.ico` and `robots.txt`)
- `default_server.enabled` can be set to false to entirely skip rendering the default server block
- Additional server blocks can be defined by adding `[server.*]` tables to config
  - `server.*.name` config must be set to an array of one or more hostname
  - `ssl_certificate` and `ssl_certificate_key` may be configured
  - `include_default_server` may be set to include the default server block's configuration. This is useful when you only need to define additional server blocks to map different hostnames+certs to the same application.
  - `snippet` config can be used to pass arbitrary nginx lines into the server block
