#!/usr/bin/env bash

set -euo pipefail

stderr() {
    echo "$@" >&2
}

if test $# -eq 0; then
    stderr "No arguments given to entrypoint."
    exit 1
fi

fabmanager list-users --app superset # Run this to report any config errors visibly. https://github.com/dpgaspar/Flask-AppBuilder/issues/742
user_count="$(fabmanager list-users --app superset | sed -n '/^username/p' | wc -l)"
if test "${user_count}" = 0; then
    stderr "No users exist. Creating admin user."
    fabmanager create-admin --app superset --username admin --password admin \
        --firstname Admin --lastname Admin --email admin@localhost
fi

stderr "Updating the database."
# This takes some time. Unfortunately, we don't know database location upfront,
# so we can't do this during container creation.
superset db upgrade
superset init

if test -v SUPERSET_CONTAINER_POST_INIT; then
    stderr "Running post-init hook ${SUPERSET_CONTAINER_POST_INIT}."
    bash -euo pipefail -c "${SUPERSET_CONTAINER_POST_INIT}"
fi

set -x
exec "$@"
