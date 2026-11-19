#!/bin/bash
# Creates the separate test database used by backend e2e tests (DATABASE_URL_TEST).
# Runs only on the first start of an empty data volume.
set -euo pipefail
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  CREATE DATABASE "${POSTGRES_TEST_DB:-gym_test}" OWNER "$POSTGRES_USER";
EOSQL
