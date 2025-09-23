SET TIMEZONE TO 'UTC';

SET check_function_bodies = false;

SET search_path = pg_catalog;

-- DEPCY: This CONSTRAINT depends on the TABLE: public.collections

ALTER TABLE public.workbooks
	DROP CONSTRAINT workbooks_collection_id_fkey;

-- DEPCY: This FUNCTION depends on the TABLE: public.collections

DROP FUNCTION public.sf_dl_remove_collection(collectionid bigint);

-- DEPCY: This CONSTRAINT depends on the TABLE: public.collections

ALTER TABLE public.collections
	DROP CONSTRAINT collections_tenant_id_fkey;

-- DEPCY: This CONSTRAINT depends on the TABLE: public.collections

ALTER TABLE public.collections
	DROP CONSTRAINT collections_parent_id_fkey;

-- DEPCY: This CONSTRAINT depends on the TABLE: public.collections

ALTER TABLE public.collections
	DROP CONSTRAINT collections_pkey;

-- DEPCY: This TRIGGER depends on the TABLE: public.collections

DROP TRIGGER before_collections_insert_or_update ON public.collections;

-- DEPCY: This INDEX depends on the TABLE: public.collections

DROP INDEX public.collections_uniq_title_idx;

-- DEPCY: This INDEX depends on the TABLE: public.collections

DROP INDEX public.collections_updated_at_idx;

-- DEPCY: This INDEX depends on the TABLE: public.collections

DROP INDEX public.collections_tenant_id_idx;

-- DEPCY: This INDEX depends on the TABLE: public.collections

DROP INDEX public.collections_sort_title_idx;

-- DEPCY: This INDEX depends on the TABLE: public.collections

DROP INDEX public.collections_parent_id_idx;

-- DEPCY: This INDEX depends on the TABLE: public.collections

DROP INDEX public.collections_created_at_idx;

DROP TABLE public.collections;

ALTER TABLE public.data_exports OWNER TO "skrmo";

ALTER TABLE public.entries OWNER TO "skrmo";

CREATE TABLE public.collections (
	collection_id bigint DEFAULT public.get_id() NOT NULL,
	title text NOT NULL,
	description text,
	parent_id bigint,
	tenant_id text DEFAULT 'common'::text NOT NULL,
	project_id text,
	created_by text NOT NULL,
	created_at timestamp with time zone DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	updated_at timestamp with time zone DEFAULT now() NOT NULL,
	deleted_by text,
	deleted_at timestamp with time zone,
	meta jsonb DEFAULT '{}'::jsonb NOT NULL,
	title_lower text NOT NULL,
	sort_title bytea NOT NULL
);

ALTER TABLE public.collections OWNER TO "skrmo";

CREATE INDEX collections_project_id_idx ON public.collections USING btree (project_id);

-- DEPCY: This CONSTRAINT is a dependency of CONSTRAINT: public.workbooks.workbooks_collection_id_fkey

ALTER TABLE public.collections
	ADD CONSTRAINT collections_pkey PRIMARY KEY (collection_id);

ALTER TABLE public.workbooks
	ADD CONSTRAINT workbooks_collection_id_fkey FOREIGN KEY (collection_id) REFERENCES public.collections(collection_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE public.collections
	ADD CONSTRAINT collections_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE public.collections
	ADD CONSTRAINT collections_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.collections(collection_id) ON UPDATE CASCADE ON DELETE CASCADE;

CREATE TRIGGER before_collections_insert_or_update
	BEFORE INSERT OR UPDATE ON public.collections
	FOR EACH ROW
	EXECUTE PROCEDURE public.update_collections();

CREATE UNIQUE INDEX collections_uniq_title_idx ON public.collections USING btree (COALESCE((parent_id)::text, project_id, tenant_id), title_lower)
WHERE (deleted_at IS NULL);

CREATE INDEX collections_updated_at_idx ON public.collections USING btree (updated_at);

CREATE INDEX collections_tenant_id_idx ON public.collections USING btree (tenant_id);

CREATE INDEX collections_sort_title_idx ON public.collections USING btree (sort_title);

CREATE INDEX collections_parent_id_idx ON public.collections USING btree (parent_id);

CREATE INDEX collections_created_at_idx ON public.collections USING btree (created_at);