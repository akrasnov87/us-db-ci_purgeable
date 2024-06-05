CREATE TABLE public.presets (
	preset_id bigint DEFAULT public.get_id() NOT NULL,
	created_at timestamp with time zone DEFAULT now() NOT NULL,
	data jsonb DEFAULT '{}'::jsonb NOT NULL
);

ALTER TABLE public.presets OWNER TO us;

--------------------------------------------------------------------------------

ALTER TABLE public.presets
	ADD CONSTRAINT presets_pkey PRIMARY KEY (preset_id);
