#!/usr/bin/env bash
set -ex
set -o pipefail

run() {
  docker-compose build
  docker-compose up
}

rerun() {
  docker kill fuzzy_postgres_speed_postgres_1
  docker rm fuzzy_postgres_speed_postgres_1
  run
}

sql() {
  psql -h localhost -p 5439 -U postgres -d people -c "$@"
}

sqla() {
  sql "EXPLAIN (ANALYZE) $*"
  sql "$@"
}

c() {
  sql "SELECT count(*) FROM person;"
}

last() {
  sql "SELECT * FROM person ORDER BY id DESC limit 5"
}

fuz() {
  sqla "SELECT * FROM person WHERE name % '8500000'"
}

"$@"
