CREATE TABLE public.data_exports (
	data_export_id bigint DEFAULT public.get_id() NOT NULL,
	title text NOT NULL,
	tenant_id text DEFAULT 'common'::text NOT NULL,
	chart_id bigint,
	chart_rev_id bigint,
	dataset_id bigint,
	dataset_rev_id bigint,
	connection_id bigint,
	connection_rev_id bigint,
	params jsonb DEFAULT '{}'::jsonb NOT NULL,
	created_by text NOT NULL,
	updated_by text,
	created_at timestamp with time zone DEFAULT now() NOT NULL,
	updated_at timestamp with time zone,
	expired_at timestamp with time zone NOT NULL,
	job_id text NOT NULL,
	s3_key text,
	error jsonb,
	upload_id text
);

ALTER TABLE public.data_exports OWNER TO us;

--------------------------------------------------------------------------------

CREATE INDEX data_exports_chart_id_idx ON public.data_exports USING btree (chart_id);

--------------------------------------------------------------------------------

CREATE INDEX data_exports_connection_id_idx ON public.data_exports USING btree (connection_id);

--------------------------------------------------------------------------------

CREATE INDEX data_exports_dataset_id_idx ON public.data_exports USING btree (dataset_id);

--------------------------------------------------------------------------------

CREATE INDEX data_exports_expired_at_idx ON public.data_exports USING btree (expired_at);

--------------------------------------------------------------------------------

ALTER TABLE public.data_exports
	ADD CONSTRAINT data_exports_chart_id_fkey FOREIGN KEY (chart_id) REFERENCES public.entries(entry_id) ON UPDATE CASCADE ON DELETE SET NULL;

--------------------------------------------------------------------------------

ALTER TABLE public.data_exports
	ADD CONSTRAINT data_exports_chart_rev_id_fkey FOREIGN KEY (chart_rev_id) REFERENCES public.revisions(rev_id) ON UPDATE CASCADE ON DELETE SET NULL;

--------------------------------------------------------------------------------

ALTER TABLE public.data_exports
	ADD CONSTRAINT data_exports_connection_id_fkey FOREIGN KEY (connection_id) REFERENCES public.entries(entry_id) ON UPDATE CASCADE ON DELETE SET NULL;

--------------------------------------------------------------------------------

ALTER TABLE public.data_exports
	ADD CONSTRAINT data_exports_connection_rev_id_fkey FOREIGN KEY (connection_rev_id) REFERENCES public.revisions(rev_id) ON UPDATE CASCADE ON DELETE SET NULL;

--------------------------------------------------------------------------------

ALTER TABLE public.data_exports
	ADD CONSTRAINT data_exports_dataset_id_fkey FOREIGN KEY (dataset_id) REFERENCES public.entries(entry_id) ON UPDATE CASCADE ON DELETE SET NULL;

--------------------------------------------------------------------------------

ALTER TABLE public.data_exports
	ADD CONSTRAINT data_exports_dataset_rev_id_fkey FOREIGN KEY (dataset_rev_id) REFERENCES public.revisions(rev_id) ON UPDATE CASCADE ON DELETE SET NULL;

--------------------------------------------------------------------------------

ALTER TABLE public.data_exports
	ADD CONSTRAINT data_exports_pkey PRIMARY KEY (data_export_id);

--------------------------------------------------------------------------------

ALTER TABLE public.data_exports
	ADD CONSTRAINT data_exports_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id) ON UPDATE CASCADE ON DELETE CASCADE;
