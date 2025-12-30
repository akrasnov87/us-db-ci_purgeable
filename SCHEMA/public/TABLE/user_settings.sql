CREATE TABLE public.user_settings (
	user_id text NOT NULL,
	settings jsonb DEFAULT '{}'::jsonb NOT NULL,
	updated_at timestamp with time zone DEFAULT now(),
	tenant_id text DEFAULT 'common'::text NOT NULL
);

ALTER TABLE public.user_settings OWNER TO "pg-user";

--------------------------------------------------------------------------------

ALTER TABLE public.user_settings
	ADD CONSTRAINT user_settings_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.user_settings
	ADD CONSTRAINT "user_settings_сomposite_pkey" PRIMARY KEY (user_id, tenant_id);
