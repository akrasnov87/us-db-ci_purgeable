CREATE TABLE public.operations (
	operation_id bigint DEFAULT public.get_id() NOT NULL,
	type text NOT NULL,
	created_at timestamp with time zone DEFAULT now() NOT NULL,
	created_by text NOT NULL,
	updated_at timestamp with time zone DEFAULT now() NOT NULL,
	result jsonb DEFAULT '{}'::jsonb NOT NULL,
	status public.operation_status_enum DEFAULT 'scheduled'::public.operation_status_enum NOT NULL,
	meta jsonb DEFAULT '{}'::jsonb NOT NULL,
	inner_meta jsonb DEFAULT '{}'::jsonb NOT NULL,
	run_after timestamp with time zone DEFAULT now() NOT NULL,
	retries_left smallint DEFAULT 3 NOT NULL,
	retries_interval_sec integer DEFAULT 180 NOT NULL,
	tenant_id text
);

ALTER TABLE public.operations OWNER TO us;

--------------------------------------------------------------------------------

CREATE INDEX operations_retries_left_run_after_idx ON public.operations USING btree (retries_left, run_after)
WHERE (status = 'scheduled'::public.operation_status_enum);

--------------------------------------------------------------------------------

ALTER TABLE public.operations
	ADD CONSTRAINT operations_pkey PRIMARY KEY (operation_id);

--------------------------------------------------------------------------------

ALTER TABLE public.operations
	ADD CONSTRAINT operations_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id) ON UPDATE CASCADE ON DELETE CASCADE;
