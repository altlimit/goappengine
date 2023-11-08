# goappengine

Using dev_appserver.py for development with 2nd gen appengine using latest golang version.

# Example Docker Compose File

Use docker-compose.yaml to run your appengine project within appengine context.

```yaml
version: "3"
services:
  backend:
    image: "ghcr.io/altlimit/goappengine:latest"
    command:
      [
        "python3",
        "/root/google-cloud-sdk/bin/dev_appserver.py",
        "--enable_host_checking=false",
        "--enable_watching_go_path=true",
        "--default_gcs_bucket_name=default",
        "--log_level=debug",
        "--admin_host=0.0.0.0",
        "--host=0.0.0.0",
        "--port=8050",
        "--storage_path=/data",
        "--runtime_python_path=/usr/bin/python3",
        "--application=app-test",
        "--support_datastore_emulator=true",
        "--datastore_consistency_policy=consistent",
        "--require_indexes=true",
        "app.yaml"
      ]
    ports:
      - "8050:8050"
    working_dir: /backend
    volumes:
      - ./backend:/backend
      - ./tmp:/data
    environment:
      GOOGLE_CLOUD_PROJECT: 'app-test'
      APPLICATION_ID: "dev~app-test"
  admin:
    image: "caddy:2-alpine"
    ports:
      - "8000:8000"
    command: >
      sh -c "echo -e \":8000 {\\n  reverse_proxy {\\n  to backend:8000\\n  header_up Origin http://0.0.0.0:8000\\n}\\n}\" > /Caddyfile && caddy run --config /Caddyfile"
    depends_on:
      - backend
```

Here is an app.yaml example to keep using the appengine bundled services and couple of helper handles for asset files.

```yaml
runtime: go120
app_engine_apis: true

instance_class: F1
automatic_scaling:
  max_instances: 10
  min_instances: 0

default_expiration: "30d"

handlers:
  - url: /(robots\.txt|favicon\.ico|manifest\.json|browserconfig\.xml|sitemap\.xml)
    static_files: dist/\1
    upload: dist/(robots\.txt|favicon\.ico|manifest\.json|browserconfig\.xml|sitemap\.xml)
    expiration: "1d"
    http_headers:
      Access-Control-Allow-Origin: "*"

  - url: /(assets)/(.*)
    static_files: dist/\1/\2
    upload: dist/(assets)/.*
    http_headers:
      Access-Control-Allow-Origin: "*"

  - url: /.*
    secure: always
    redirect_http_response_code: 301
    script: auto
```