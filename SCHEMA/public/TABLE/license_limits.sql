CREATE TABLE public.license_limits (
	license_limit_id bigint DEFAULT public.get_id() NOT NULL,
	meta jsonb DEFAULT '{}'::jsonb NOT NULL,
	tenant_id text DEFAULT 'common'::text NOT NULL,
	type public.license_limit_type_enum NOT NULL,
	started_at timestamp with time zone NOT NULL,
	creators_limit_value integer NOT NULL,
	created_by text NOT NULL,
	created_at timestamp with time zone DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE public.license_limits OWNER TO "pg-user";

--------------------------------------------------------------------------------

CREATE INDEX license_limits_creators_limit_value_idx ON public.license_limits USING btree (creators_limit_value);

--------------------------------------------------------------------------------

CREATE INDEX license_limits_started_at_idx ON public.license_limits USING btree (started_at);

--------------------------------------------------------------------------------

CREATE INDEX license_limits_tenant_id_started_at_desc_idx ON public.license_limits USING btree (tenant_id, started_at DESC);

--------------------------------------------------------------------------------

ALTER TABLE public.license_limits
	ADD CONSTRAINT license_limits_pkey PRIMARY KEY (license_limit_id);

--------------------------------------------------------------------------------

ALTER TABLE public.license_limits
	ADD CONSTRAINT license_limits_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id) ON UPDATE CASCADE ON DELETE CASCADE;
