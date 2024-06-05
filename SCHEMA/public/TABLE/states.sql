CREATE TABLE public.states (
	hash text NOT NULL,
	entry_id bigint NOT NULL,
	data jsonb,
	created_at timestamp with time zone DEFAULT now()
);

ALTER TABLE public.states OWNER TO us;

--------------------------------------------------------------------------------

CREATE INDEX states_entry_id_idx ON public.states USING btree (entry_id);

--------------------------------------------------------------------------------

ALTER TABLE public.states
	ADD CONSTRAINT states_entries_id FOREIGN KEY (entry_id) REFERENCES public.entries(entry_id) ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.states
	ADD CONSTRAINT states_pkey PRIMARY KEY (hash, entry_id);
