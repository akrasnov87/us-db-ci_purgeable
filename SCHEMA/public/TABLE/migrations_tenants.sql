CREATE TABLE public.migrations_tenants (
	from_id text NOT NULL,
	to_id text NOT NULL,
	migrating boolean DEFAULT true NOT NULL,
	migration_meta jsonb DEFAULT '{}'::jsonb NOT NULL,
	created_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE public.migrations_tenants OWNER TO us;

--------------------------------------------------------------------------------

ALTER TABLE public.migrations_tenants
	ADD CONSTRAINT migrations_tenants_pkey PRIMARY KEY (from_id, to_id);
