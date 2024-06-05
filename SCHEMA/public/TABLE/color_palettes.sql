CREATE TABLE public.color_palettes (
	color_palette_id bigint DEFAULT public.get_id() NOT NULL,
	tenant_id text DEFAULT 'common'::text NOT NULL,
	name text NOT NULL,
	display_name text NOT NULL,
	colors jsonb DEFAULT '[]'::jsonb NOT NULL,
	is_gradient boolean DEFAULT false NOT NULL,
	is_default boolean DEFAULT false NOT NULL
);

ALTER TABLE public.color_palettes OWNER TO us;

--------------------------------------------------------------------------------

CREATE INDEX color_palettes_tenant_id_idx ON public.color_palettes USING btree (tenant_id);

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX color_palettes_uniq_default_for_tenant_id_idx ON public.color_palettes USING btree (tenant_id, is_default, is_gradient)
WHERE (is_default = true);

--------------------------------------------------------------------------------

ALTER TABLE public.color_palettes
	ADD CONSTRAINT color_palettes_non_empty_name_constraint CHECK ((btrim(name) <> ''::text));

--------------------------------------------------------------------------------

ALTER TABLE public.color_palettes
	ADD CONSTRAINT color_palettes_pkey PRIMARY KEY (color_palette_id);

--------------------------------------------------------------------------------

ALTER TABLE public.color_palettes
	ADD CONSTRAINT color_palettes_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.color_palettes
	ADD CONSTRAINT color_palettes_uniq_name_constraint UNIQUE (tenant_id, name);
