CREATE TABLE public.workbooks (
	workbook_id bigint DEFAULT public.get_id() NOT NULL,
	title text NOT NULL,
	description text,
	project_id text,
	tenant_id text DEFAULT 'common'::text NOT NULL,
	meta jsonb DEFAULT '{}'::jsonb NOT NULL,
	created_by text NOT NULL,
	created_at timestamp with time zone DEFAULT now() NOT NULL,
	deleted_at timestamp with time zone,
	is_template boolean DEFAULT false,
	collection_id bigint,
	deleted_by text,
	updated_by text,
	updated_at timestamp with time zone DEFAULT now() NOT NULL,
	title_lower text NOT NULL,
	sort_title bytea NOT NULL
);

ALTER TABLE public.workbooks OWNER TO us;

--------------------------------------------------------------------------------

CREATE INDEX workbooks_collection_id_idx ON public.workbooks USING btree (collection_id);

--------------------------------------------------------------------------------

CREATE INDEX workbooks_created_at_idx ON public.workbooks USING btree (created_at);

--------------------------------------------------------------------------------

CREATE INDEX workbooks_project_id_idx ON public.workbooks USING btree (project_id);

--------------------------------------------------------------------------------

CREATE INDEX workbooks_sort_title_idx ON public.workbooks USING btree (sort_title);

--------------------------------------------------------------------------------

CREATE INDEX workbooks_tenant_id_idx ON public.workbooks USING btree (tenant_id);

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX workbooks_uniq_title_idx ON public.workbooks USING btree (COALESCE((collection_id)::text, project_id, tenant_id), title_lower)
WHERE (deleted_at IS NULL);

--------------------------------------------------------------------------------

CREATE INDEX workbooks_updated_at_idx ON public.workbooks USING btree (updated_at);

--------------------------------------------------------------------------------

CREATE TRIGGER before_workbooks_insert_or_update
	BEFORE INSERT OR UPDATE ON public.workbooks
	FOR EACH ROW
	EXECUTE PROCEDURE public.update_workbooks();

--------------------------------------------------------------------------------

ALTER TABLE public.workbooks
	ADD CONSTRAINT workbooks_collection_id_fkey FOREIGN KEY (collection_id) REFERENCES public.collections(collection_id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.workbooks
	ADD CONSTRAINT workbooks_pkey PRIMARY KEY (workbook_id);

--------------------------------------------------------------------------------

ALTER TABLE public.workbooks
	ADD CONSTRAINT workbooks_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id) ON UPDATE CASCADE ON DELETE CASCADE;
