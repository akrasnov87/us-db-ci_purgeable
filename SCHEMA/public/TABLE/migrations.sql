CREATE TABLE public.migrations (
	id integer DEFAULT nextval('public.migrations_id_seq'::regclass) NOT NULL,
	name character varying(255),
	batch integer,
	migration_time timestamp with time zone
);

ALTER TABLE public.migrations OWNER TO us;

--------------------------------------------------------------------------------

ALTER TABLE public.migrations
	ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);
