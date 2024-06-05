CREATE TABLE public.migrations_lock (
	index integer DEFAULT nextval('public.migrations_lock_index_seq'::regclass) NOT NULL,
	is_locked integer
);

ALTER TABLE public.migrations_lock OWNER TO us;

--------------------------------------------------------------------------------

ALTER TABLE public.migrations_lock
	ADD CONSTRAINT migrations_lock_pkey PRIMARY KEY (index);
