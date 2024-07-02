CREATE TABLE public.tenants (
	tenant_id text NOT NULL,
	meta jsonb DEFAULT '{}'::jsonb,
	created_at timestamp with time zone DEFAULT now(),
	enabled boolean DEFAULT false NOT NULL,
	deleting boolean DEFAULT false NOT NULL,
	last_init_at timestamp with time zone DEFAULT now() NOT NULL,
	retries_count integer DEFAULT 0 NOT NULL,
	collections_enabled boolean DEFAULT false NOT NULL,
	folders_enabled boolean DEFAULT true NOT NULL,
	billing_instance_service_id character varying(255) DEFAULT NULL::character varying,
	billing_started_at timestamp with time zone,
	branding jsonb DEFAULT '{}'::jsonb NOT NULL,
	billing_paused_by_user boolean DEFAULT false NOT NULL,
	billing_instance_service_is_active boolean DEFAULT false NOT NULL,
	billing_ended_at timestamp with time zone,
	settings jsonb DEFAULT '{}'::jsonb
);

ALTER TABLE public.tenants OWNER TO us;

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX tenants_billing_instance_service_id_idx ON public.tenants USING btree (billing_instance_service_id);

--------------------------------------------------------------------------------

CREATE INDEX tenants_enabled_idx ON public.tenants USING btree (enabled);

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX tenants_tenant_id_uindex ON public.tenants USING btree (tenant_id);

--------------------------------------------------------------------------------

ALTER TABLE public.tenants
	ADD CONSTRAINT tenants_pkey PRIMARY KEY (tenant_id);
