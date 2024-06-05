CREATE SEQUENCE public.migrations_lock_index_seq
	AS integer
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE public.migrations_lock_index_seq OWNER TO us;

ALTER SEQUENCE public.migrations_lock_index_seq
	OWNED BY public.migrations_lock.index;
