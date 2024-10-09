CREATE TABLE public.entries (
	scope public.scope,
	type text NOT NULL,
	key text,
	inner_meta jsonb,
	created_by text NOT NULL,
	created_at timestamp with time zone DEFAULT now(),
	updated_by text NOT NULL,
	updated_at timestamp with time zone DEFAULT now(),
	is_deleted boolean DEFAULT false,
	deleted_at timestamp with time zone,
	hidden boolean DEFAULT false,
	display_key text,
	entry_id bigint DEFAULT public.get_id() NOT NULL,
	saved_id bigint,
	published_id bigint,
	tenant_id text,
	name text,
	sort_name bytea,
	public boolean DEFAULT false,
	unversioned_data jsonb DEFAULT '{}'::jsonb,
	workbook_id bigint,
	mirrored boolean DEFAULT false
);

ALTER TABLE public.entries OWNER TO us;

--------------------------------------------------------------------------------

CREATE INDEX entries_created_at_idx ON public.entries USING btree (created_at);

--------------------------------------------------------------------------------

CREATE INDEX entries_root_tenant_id_idx ON public.entries USING btree (tenant_id)
WHERE (key !~~ '_%/_%'::text);

--------------------------------------------------------------------------------

CREATE INDEX entries_updated_at_idx ON public.entries USING btree (updated_at);

--------------------------------------------------------------------------------

CREATE INDEX entries_workbook_id_idx ON public.entries USING btree (workbook_id);

--------------------------------------------------------------------------------

CREATE INDEX key_idx ON public.entries USING gin (key public.gin_trgm_ops);

--------------------------------------------------------------------------------

CREATE INDEX name_idx ON public.entries USING btree (name);

--------------------------------------------------------------------------------

CREATE INDEX public_idx ON public.entries USING btree (public);

--------------------------------------------------------------------------------

CREATE INDEX sort_name_idx ON public.entries USING btree (sort_name);

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX tenant_id_key_idx ON public.entries USING btree (tenant_id, key);

--------------------------------------------------------------------------------

CREATE TRIGGER before_entries_insert_or_update
	BEFORE INSERT OR UPDATE ON public.entries
	FOR EACH ROW
	EXECUTE PROCEDURE public.update_entries();

--------------------------------------------------------------------------------

ALTER TABLE public.entries
	ADD CONSTRAINT entries_pkey PRIMARY KEY (entry_id);

--------------------------------------------------------------------------------

ALTER TABLE public.entries
	ADD CONSTRAINT entries_tenants_id FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.entries
	ADD CONSTRAINT entries_uniq_entry_id_tenant_id_constraint UNIQUE (entry_id, tenant_id);

--------------------------------------------------------------------------------

ALTER TABLE public.entries
	ADD CONSTRAINT entries_workbook_id_ref FOREIGN KEY (workbook_id) REFERENCES public.workbooks(workbook_id) ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.entries
	ADD CONSTRAINT uniq_scope_name_workbook_id UNIQUE (scope, name, workbook_id);
