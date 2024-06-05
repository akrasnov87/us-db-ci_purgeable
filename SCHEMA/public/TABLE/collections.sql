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

ALTER TABLE public.collections OWNER TO us;

--------------------------------------------------------------------------------

CREATE INDEX collections_created_at_idx ON public.collections USING btree (created_at);

--------------------------------------------------------------------------------

CREATE INDEX collections_parent_id_idx ON public.collections USING btree (parent_id);

--------------------------------------------------------------------------------

CREATE INDEX collections_project_id_idx ON public.collections USING btree (project_id);

--------------------------------------------------------------------------------

CREATE INDEX collections_sort_title_idx ON public.collections USING btree (sort_title);

--------------------------------------------------------------------------------

CREATE INDEX collections_tenant_id_idx ON public.collections USING btree (tenant_id);

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX collections_uniq_title_idx ON public.collections USING btree (COALESCE((parent_id)::text, project_id, tenant_id), title_lower)
WHERE (deleted_at IS NULL);

--------------------------------------------------------------------------------

CREATE INDEX collections_updated_at_idx ON public.collections USING btree (updated_at);

--------------------------------------------------------------------------------

CREATE TRIGGER before_collections_insert_or_update
	BEFORE INSERT OR UPDATE ON public.collections
	FOR EACH ROW
	EXECUTE PROCEDURE public.update_collections();

--------------------------------------------------------------------------------

ALTER TABLE public.collections
	ADD CONSTRAINT collections_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.collections(collection_id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.collections
	ADD CONSTRAINT collections_pkey PRIMARY KEY (collection_id);

--------------------------------------------------------------------------------

ALTER TABLE public.collections
	ADD CONSTRAINT collections_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id) ON UPDATE CASCADE ON DELETE CASCADE;
