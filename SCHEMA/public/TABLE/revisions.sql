CREATE TABLE public.revisions (
	data jsonb,
	meta jsonb,
	created_by text NOT NULL,
	created_at timestamp with time zone DEFAULT now(),
	updated_by text NOT NULL,
	updated_at timestamp with time zone DEFAULT now(),
	rev_id bigint DEFAULT public.get_id() NOT NULL,
	entry_id bigint,
	links jsonb
);

ALTER TABLE public.revisions OWNER TO us;

--------------------------------------------------------------------------------

CREATE INDEX revisions_entry_id_idx ON public.revisions USING btree (entry_id);

--------------------------------------------------------------------------------

CREATE INDEX revisions_meta_mdb_cluster_id_index ON public.revisions USING gin (((meta ->> 'mdb_cluster_id'::text)));

--------------------------------------------------------------------------------

CREATE INDEX revisions_updated_at_idx ON public.revisions USING btree (updated_at);

--------------------------------------------------------------------------------

ALTER TABLE public.revisions
	ADD CONSTRAINT revisions_entries_id FOREIGN KEY (entry_id) REFERENCES public.entries(entry_id) ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.revisions
	ADD CONSTRAINT revisions_pkey PRIMARY KEY (rev_id);
