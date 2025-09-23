CREATE TABLE public.templates (
	name text NOT NULL,
	data jsonb
);

ALTER TABLE public.templates OWNER TO "pg-user";

--------------------------------------------------------------------------------

ALTER TABLE public.templates
	ADD CONSTRAINT templates_pkey PRIMARY KEY (name);
