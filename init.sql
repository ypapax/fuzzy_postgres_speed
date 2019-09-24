CREATE DATABASE people;
\connect people;
CREATE TABLE people
(
    id        bigserial NOT NULL,
    name      text      NULL,
    metaphone text      NULL
);

CREATE EXTENSION fuzzystrmatch;
CREATE EXTENSION pg_trgm;

CREATE INDEX name_trigram_idx ON people USING gin (name gin_trgm_ops);
CREATE INDEX metaphone_binary_idx ON people USING btree (metaphone ASC);