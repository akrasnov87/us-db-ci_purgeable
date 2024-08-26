START TRANSACTION;

ALTER TABLE core.pd_accesses
  DROP CONSTRAINT pd_accesses_pkey;

ALTER TABLE core.pd_accesses
  ALTER COLUMN id TYPE integer USING id::integer; /* ТИП колонки изменился - Таблица: core.pd_accesses оригинал: smallint новый: integer */

ALTER TABLE core.pd_accesses
  ADD CONSTRAINT pd_accesses_pkey PRIMARY KEY (id);
  
COMMIT TRANSACTION;