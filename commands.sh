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
  #  sqla "SELECT * FROM people WHERE name % 'amnesties Wilder ledge perception falconer'"
  #   Gather  (cost=1000.00..137105.65 rows=8501 width=55) (actual time=14847.954..36051.803 rows=2 loops=1)
  #   Workers Planned: 2
  #   Workers Launched: 2
  #   ->  Parallel Seq Scan on people  (cost=0.00..135255.55 rows=3542 width=55) (actual time=28980.157..36047.508 rows=1 loops=3)
  #         Filter: (name % 'amnesties Wilder ledge perception falconer'::text)
  #         Rows Removed by Filter: 2833333
  # Planning Time: 2.657 ms
  # Execution Time: 36051.986 ms
  #    sqla "SELECT * FROM people WHERE SIMILARITY(name, 'amnesties Wilder ledge perception falconer') > 0.4"
  #----------------------------------------------------------------------------------------------------------------------
  # Seq Scan on people  (cost=0.00..218491.70 rows=2833571 width=55) (actual time=105761.464..105761.509 rows=1 loops=1)
  #   Filter: (similarity(name, 'amnesties Wilder ledge perception falconer'::text) > '0.4'::double precision)
  #   Rows Removed by Filter: 8499999
  # Planning Time: 1.407 ms
  # Execution Time: 105762.077 ms
  #(5 rows)
  #  sqla "SELECT * FROM people WHERE SIMILARITY(name, 'amnesties Wilder ledge perception falconer') > 0.1"
  # Seq Scan on people  (cost=0.00..218491.70 rows=2833571 width=55) (actual time=0.792..108442.755 rows=138062 loops=1)
  #   Filter: (similarity(name, 'amnesties Wilder ledge perception falconer'::text) > '0.1'::double precision)
  #   Rows Removed by Filter: 8361938
  # Planning Time: 0.353 ms
  # Execution Time: 109291.338 ms
  #  sqla "SELECT * FROM people WHERE LEVENSHTEIN(name, 'amnesties Wilder ledge perception falconer') < 5"
  #   Seq Scan on people  (cost=0.00..218491.70 rows=2833571 width=55) (actual time=9036.638..35391.910 rows=1 loops=1)
  #   Filter: (levenshtein(name, 'amnesties Wilder ledge perception falconer'::text) < 5)
  #   Rows Removed by Filter: 8499999
  # Planning Time: 0.290 ms
  # Execution Time: 35392.373 ms
  #(5 rows)
  #
  #+(./commands.sh:24): sqla():  myMac $ sql 'SELECT * FROM people WHERE LEVENSHTEIN(name, '\''amnesties Wilder ledge perception falconer'\'') < 5'
  #+(./commands.sh:19): sql():  myMac $ psql -h localhost -p 5439 -U postgres -d people -c 'SELECT * FROM people WHERE LEVENSHTEIN(name, '\''amnesties Wilder ledge perception falconer'\'') < 5'
  #   id    |                    name
  #---------+---------------------------------------------
  # 8499997 | amnesties Wilder ledge perceptions falconer
  #(1 row)

  #  sqla "SELECT count(*) FROM people WHERE SOUNDEX(name) = SOUNDEX('amnesties Wilder ledge perception falconer')"
  #  sqla "SELECT * FROM people WHERE SOUNDEX(name) = SOUNDEX('amnesties Wilder ledge perception falconer')"
  #   count
  #-------
  #  5605
  # Gather  (cost=1000.00..149360.86 rows=42504 width=55) (actual time=0.492..766.034 rows=5605 loops=1)
  #   Workers Planned: 2
  #   Workers Launched: 2
  #   ->  Parallel Seq Scan on people  (cost=0.00..144110.46 rows=17710 width=55) (actual time=0.764..759.717 rows=1868 loops=3)
  #         Filter: (soundex(name) = 'A523'::text)
  #         Rows Removed by Filter: 2831465
  # Planning Time: 0.688 ms
  # Execution Time: 799.429 ms
  #  sqla "SELECT * FROM people WHERE METAPHONE(name, 10) = METAPHONE('amnesties Wilder ledge perception falconer', 10)"
  #-----------------------------------------------------------------------------------------------------------------------------
  # Gather  (cost=1000.00..149360.86 rows=42504 width=55) (actual time=1170.171..1171.998 rows=1 loops=1)
  #   Workers Planned: 2
  #   Workers Launched: 2
  #   ->  Parallel Seq Scan on people  (cost=0.00..144110.46 rows=17710 width=55) (actual time=879.601..1167.020 rows=0 loops=3)
  #         Filter: (metaphone(name, 10) = 'AMNSTSWLTR'::text)
  #         Rows Removed by Filter: 2833333
  # Planning Time: 0.745 ms
  # Execution Time: 1172.109 ms
  #(8 rows)
  #
  #+(./commands.sh:24): sqla():  myMac $ sql 'SELECT * FROM people WHERE METAPHONE(name, 10) = METAPHONE('\''amnesties Wilder ledge perception falconer'\'', 10)'
  #+(./commands.sh:19): sql():  myMac $ psql -h localhost -p 5439 -U postgres -d people -c 'SELECT * FROM people WHERE METAPHONE(name, 10) = METAPHONE('\''amnesties Wilder ledge perception falconer'\'', 10)'
  #   id    |                    name
  #---------+---------------------------------------------
  # 8499997 | amnesties Wilder ledge perceptions falconer
  #(1 row)
  #  sqla "SELECT * FROM people WHERE METAPHONE(name, 8) = METAPHONE('amnesties Wilder ledge perception falconer', 8)"
  #   Gather  (cost=1000.00..149360.86 rows=42504 width=55) (actual time=83.806..1051.563 rows=3 loops=1)
  #   Workers Planned: 2
  #   Workers Launched: 2
  #   ->  Parallel Seq Scan on people  (cost=0.00..144110.46 rows=17710 width=55) (actual time=425.120..1044.081 rows=1 loops=3)
  #         Filter: (metaphone(name, 8) = 'AMNSTSWL'::text)
  #         Rows Removed by Filter: 2833332
  # Planning Time: 1.460 ms
  # Execution Time: 1051.703 ms
  #(8 rows)
  #
  #+(./commands.sh:24): sqla():  myMac $ sql 'SELECT * FROM people WHERE METAPHONE(name, 8) = METAPHONE('\''amnesties Wilder ledge perception falconer'\'', 8)'
  #+(./commands.sh:19): sql():  myMac $ psql -h localhost -p 5439 -U postgres -d people -c 'SELECT * FROM people WHERE METAPHONE(name, 8) = METAPHONE('\''amnesties Wilder ledge perception falconer'\'', 8)'
  #   id    |                    name
  #---------+---------------------------------------------
  # 8499997 | amnesties Wilder ledge perceptions falconer
  # 6914400 | amnesty's wail's douched bombshell's blue's
  # 5395167 | amnesty's Wilhelm martyrdom's Olaf's Hus's
  #(3 rows)
  #  sqla "SELECT * FROM people WHERE DMETAPHONE(name) = DMETAPHONE('amnesties Wilder ledge perception falconer')"
  #                                                          QUERY PLAN
  #-------------------------------------------------------------------------------------------------------------------------------
  # Gather  (cost=1000.00..149360.86 rows=42504 width=55) (actual time=4.187..1909.798 rows=4928 loops=1)
  #   Workers Planned: 2
  #   Workers Launched: 2
  #   ->  Parallel Seq Scan on people  (cost=0.00..144110.46 rows=17710 width=55) (actual time=3.506..1902.885 rows=1643 loops=3)
  #         Filter: (dmetaphone(name) = 'AMNS'::text)
  #         Rows Removed by Filter: 2831691
  # Planning Time: 1.313 ms
  # Execution Time: 1938.173 ms
  #(8 rows)
  #
  #+(./commands.sh:24): sqla():  myMac $ sql 'SELECT * FROM people WHERE DMETAPHONE(name) = DMETAPHONE('\''amnesties Wilder ledge perception falconer'\'')'
  #+(./commands.sh:19): sql():  myMac $ psql -h localhost -p 5439 -U postgres -d people -c 'SELECT * FROM people WHERE DMETAPHONE(name) = DMETAPHONE('\''amnesties Wilder ledge perception falconer'\'')'
  #   id    |                                 name
  #---------+-----------------------------------------------------------------------
  # 6334323 | amniocentesis credo freight seething oarsman
  # 6331645 | amnesty's moisture downswing chattel's angling's
  # 6376625 | immunizing correcter voicemails mango Karla's
  # 6337984 | omen's fillies dungaree's tightwad's tent's
  # 6338806 | amnesia acquiescent characterizations construes feeler
  sqla "SELECT * FROM people WHERE metaphone=METAPHONE('bikes recuperating braved stolidest riffs', 10)"
}

update() {
  sql "UPDATE people SET metaphone=METAPHONE(name, 10)"
}

"$@"
