#!/usr/bin/env bash
set -ex
set -o pipefail

run() {
  docker-compose build
  docker-compose up
}

rerun() {
  set +e;
  docker kill fuzzy_postgres_speed_postgres_1
  docker rm fuzzy_postgres_speed_postgres_1
  set -e;
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
#  sqla "SELECT * FROM person WHERE name % '1100011'"
  sqla "SELECT * FROM person WHERE name % '120000085000008500000RN3SGD19HYZXYEK9TM0WQW1W1F62PMI6ZDP5GH5M5VAUZKUIWL'"
# Planning Time: 0.947 ms
# Execution Time: 243752.916 ms
}


"$@"
