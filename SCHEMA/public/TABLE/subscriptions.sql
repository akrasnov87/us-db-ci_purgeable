CREATE TABLE public.subscriptions (
	subscription_id bigint DEFAULT public.get_id() NOT NULL,
	title text NOT NULL,
	description text,
	meta jsonb DEFAULT '{}'::jsonb NOT NULL,
	status public.subscription_status_enum DEFAULT 'active'::public.subscription_status_enum NOT NULL,
	tenant_id text DEFAULT 'common'::text NOT NULL,
	workbook_id bigint NOT NULL,
	created_by text NOT NULL,
	created_at timestamp with time zone DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	updated_at timestamp with time zone DEFAULT now() NOT NULL,
	suspended_at timestamp with time zone,
	content_type public.subscription_content_type_enum NOT NULL,
	content_entry_id bigint NOT NULL,
	content_options jsonb DEFAULT '{}'::jsonb NOT NULL,
	trigger_type public.subscription_trigger_type_enum NOT NULL,
	trigger_entry_id bigint,
	trigger_options jsonb DEFAULT '{}'::jsonb NOT NULL,
	artifact_type public.subscription_artifact_type_enum NOT NULL,
	artifact_options jsonb DEFAULT '{}'::jsonb NOT NULL
);

ALTER TABLE public.subscriptions OWNER TO "pg-user";

--------------------------------------------------------------------------------

CREATE INDEX subscriptions_tenant_id_content_entry_id_idx ON public.subscriptions USING btree (tenant_id, content_entry_id);

--------------------------------------------------------------------------------

CREATE INDEX subscriptions_tenant_id_created_by_idx ON public.subscriptions USING btree (tenant_id, created_by);

--------------------------------------------------------------------------------

CREATE INDEX subscriptions_tenant_id_workbook_id_created_at_desc_idx ON public.subscriptions USING btree (tenant_id, workbook_id, created_at DESC);

--------------------------------------------------------------------------------

CREATE INDEX subscriptions_title_description_trgm_idx ON public.subscriptions USING gin ((((title || ' '::text) || description)) public.gin_trgm_ops);

--------------------------------------------------------------------------------

ALTER TABLE public.subscriptions
	ADD CONSTRAINT subscriptions_content_entry_id_fkey FOREIGN KEY (content_entry_id) REFERENCES public.entries(entry_id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.subscriptions
	ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (subscription_id);

--------------------------------------------------------------------------------

ALTER TABLE public.subscriptions
	ADD CONSTRAINT subscriptions_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.subscriptions
	ADD CONSTRAINT subscriptions_trigger_entry_id_fkey FOREIGN KEY (trigger_entry_id) REFERENCES public.entries(entry_id) ON UPDATE CASCADE ON DELETE SET NULL;

--------------------------------------------------------------------------------

ALTER TABLE public.subscriptions
	ADD CONSTRAINT subscriptions_workbook_id_fkey FOREIGN KEY (workbook_id) REFERENCES public.workbooks(workbook_id) ON UPDATE CASCADE ON DELETE CASCADE;
