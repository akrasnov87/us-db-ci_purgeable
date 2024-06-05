CREATE TABLE public.user_settings (
	user_id text NOT NULL,
	settings jsonb DEFAULT '{}'::jsonb NOT NULL,
	updated_at timestamp with time zone DEFAULT now()
);

ALTER TABLE public.user_settings OWNER TO us;

--------------------------------------------------------------------------------

ALTER TABLE public.user_settings
	ADD CONSTRAINT user_settings_pkey PRIMARY KEY (user_id);
