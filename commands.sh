#!/usr/bin/env bash
set -ex
set -o pipefail

run() {
  docker-compose build
  docker-compose up
}

rerun() {
  set +e
  docker kill fuzzy_postgres_speed_postgres_1
  docker rm fuzzy_postgres_speed_postgres_1
  set -e
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
  sql "SELECT count(*) FROM people;"
}

last() {
  sql "SELECT * FROM people ORDER BY id DESC limit 5"
}

fuz() {
  #  sqla "SELECT * FROM people WHERE name % '1100011'"
  #  sqla "SELECT * FROM people WHERE name % '120000085000008500000RN3SGD19HYZXYEK9TM0WQW1W1F62PMI6ZDP5GH5M5VAUZKUIWL'"
  # Planning Time: 0.947 ms
  # Execution Time: 243752.916 ms
  #    sqla "SELECT * FROM people WHERE name % '1200000'"
  # Planning Time: 1.091 ms
  # Execution Time: 928.161 ms
  #  sqla "SELECT * FROM people WHERE '1200000' % ANY(STRING_TO_ARRAY(name,' '))"
  #Planning Time: 0.505 ms
  # Execution Time: 23787.588 ms
  sqla "SELECT * FROM people WHERE name % 'amnesties Wilder ledge perception falconer'"
  #   Gather  (cost=1000.00..137105.65 rows=8501 width=55) (actual time=14847.954..36051.803 rows=2 loops=1)
  #   Workers Planned: 2
  #   Workers Launched: 2
  #   ->  Parallel Seq Scan on people  (cost=0.00..135255.55 rows=3542 width=55) (actual time=28980.157..36047.508 rows=1 loops=3)
  #         Filter: (name % 'amnesties Wilder ledge perception falconer'::text)
  #         Rows Removed by Filter: 2833333
  # Planning Time: 2.657 ms
  # Execution Time: 36051.986 ms
}

"$@"
