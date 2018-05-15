#!/usr/bin/env bash

set -euo pipefail

stderr() {
    echo "$@" >&2
}

if test $# -eq 0; then
    stderr "No arguments given to entrypoint."
    exit 1
fi

SUPERSET_ADMIN_USERNAME="${SUPERSET_ADMIN_USERNAME-admin}"
SUPERSET_ADMIN_PASSWORD="${SUPERSET_ADMIN_PASSWORD:-admin}"
if test ! -z "${SUPERSET_ADMIN_USERNAME}"; then
    fabmanager list-users --app superset # Run this to report any config errors visibly. https://github.com/dpgaspar/Flask-AppBuilder/issues/742
    user_count="$(fabmanager list-users --app superset | sed -n "/^username:${SUPERSET_ADMIN_USERNAME}\b/p" | wc -l)"
    if test "${user_count}" = 0; then
        stderr "Creating '${SUPERSET_ADMIN_USERNAME}' admin user."
        fabmanager create-admin --app superset \
            --username "${SUPERSET_ADMIN_USERNAME}" --password "${SUPERSET_ADMIN_PASSWORD}" \
            --firstname Admin --lastname Admin --email admin@localhost
    fi
fi
unset SUPERSET_ADMIN_PASSWORD

stderr "Updating the database."
# This takes some time. Unfortunately, we don't know database location upfront,
# so we can't do this during container creation.
superset db upgrade
superset init

if test -v SUPERSET_POST_INIT; then
    stderr "Running post-init hook ${SUPERSET_POST_INIT}."
    bash -euo pipefail -c "${SUPERSET_POST_INIT}"
fi

set -x
exec "$@"
