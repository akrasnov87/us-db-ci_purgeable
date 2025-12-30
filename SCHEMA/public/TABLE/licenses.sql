CREATE TABLE public.licenses (
	license_id bigint DEFAULT public.get_id() NOT NULL,
	meta jsonb DEFAULT '{}'::jsonb NOT NULL,
	tenant_id text DEFAULT 'common'::text NOT NULL,
	user_id text NOT NULL,
	license_type public.license_type_enum NOT NULL,
	expires_at timestamp with time zone,
	created_by text NOT NULL,
	created_at timestamp with time zone DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE public.licenses OWNER TO "pg-user";

--------------------------------------------------------------------------------

CREATE INDEX licenses_tenant_id_created_at_idx ON public.licenses USING btree (tenant_id, created_at);

--------------------------------------------------------------------------------

CREATE INDEX licenses_tenant_id_expires_at_idx ON public.licenses USING btree (tenant_id, expires_at);

--------------------------------------------------------------------------------

CREATE INDEX licenses_tenant_id_license_type_expires_at_idx ON public.licenses USING btree (tenant_id, license_type, expires_at);

--------------------------------------------------------------------------------

CREATE INDEX licenses_tenant_id_updated_at_idx ON public.licenses USING btree (tenant_id, updated_at);

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX licenses_tenant_id_user_id_license_type_unique_idx ON public.licenses USING btree (tenant_id, user_id, license_type);

--------------------------------------------------------------------------------

ALTER TABLE public.licenses
	ADD CONSTRAINT licenses_pkey PRIMARY KEY (license_id);

--------------------------------------------------------------------------------

ALTER TABLE public.licenses
	ADD CONSTRAINT licenses_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id) ON UPDATE CASCADE ON DELETE CASCADE;
