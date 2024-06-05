CREATE TABLE public.locks (
	lock_id bigint DEFAULT public.get_id() NOT NULL,
	entry_id bigint NOT NULL,
	lock_token text NOT NULL,
	expiry_date timestamp with time zone NOT NULL,
	login text,
	start_date timestamp with time zone DEFAULT now()
);

ALTER TABLE public.locks OWNER TO us;

--------------------------------------------------------------------------------

CREATE INDEX locks_entry_id_idx ON public.locks USING btree (entry_id);

--------------------------------------------------------------------------------

ALTER TABLE public.locks
	ADD CONSTRAINT locks_entries_id FOREIGN KEY (entry_id) REFERENCES public.entries(entry_id) ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.locks
	ADD CONSTRAINT locks_pkey PRIMARY KEY (lock_id);

--------------------------------------------------------------------------------

ALTER TABLE public.locks
	ADD CONSTRAINT uniq_active_lock_per_entry_id EXCLUDE USING gist (entry_id WITH =, tstzrange(start_date, expiry_date) WITH &&) WHERE ((expiry_date > start_date));
