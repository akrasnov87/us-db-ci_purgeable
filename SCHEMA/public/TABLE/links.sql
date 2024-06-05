CREATE TABLE public.links (
	from_id bigint NOT NULL,
	to_id bigint NOT NULL,
	name text NOT NULL
);

ALTER TABLE public.links OWNER TO us;

--------------------------------------------------------------------------------

CREATE INDEX from_id_idx ON public.links USING btree (from_id);

--------------------------------------------------------------------------------

CREATE INDEX to_id_idx ON public.links USING btree (to_id);

--------------------------------------------------------------------------------

ALTER TABLE public.links
	ADD CONSTRAINT links_pkey PRIMARY KEY (from_id, to_id, name);
