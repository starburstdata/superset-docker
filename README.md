# Superset docker container

## Container characteristic

- superset running with gunicorn on port 8088
- `/superset` mounted as a volume and set as `SUPERSET_HOME`
  - by default, Superset manages its configuration in an Sqlite database within
    `SUPERSET_HOME`, but this can be configured with `SUPERSET_CONFIG_PATH`.
- admin user created

## Usage

```bash
docker run starburstdata/superset
```

## Configuration options

- Custom configuration (`superset_config.py`): mount a folder with the configuration
  file (typically named `superset_config.py`) and set the path to the file in env
  `SUPERSET_CONFIG_PATH`.
- Custom additional initialization, after Superset database is updated: mount a script
  and set the path to it in env `SUPERSET_CONTAINER_POST_INIT`. (Actually,
  `SUPERSET_CONTAINER_POST_INIT` is interpreted with a shell, so you can use this env var
  to pass both program location and arguments.)
- Custom additional initialization: if you want to skip all initialization done by the
  container by default, override the entrypoint.
