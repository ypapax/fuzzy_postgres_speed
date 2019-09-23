CREATE DATABASE people;
\connect people;
CREATE TABLE person
(
    id   bigserial NOT NULL,
    name text      NULL
);

CREATE EXTENSION fuzzystrmatch;
CREATE EXTENSION pg_trgm;

CREATE INDEX name_trigram_idx ON person USING gin (name gin_trgm_ops);

INSERT INTO person (name)
SELECT CONCAT(g.name, g.name, g.name, g.name)
FROM generate_series(1, 8500000) AS g (name);