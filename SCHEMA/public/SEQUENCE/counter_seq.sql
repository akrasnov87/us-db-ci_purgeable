CREATE SEQUENCE public.counter_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE public.counter_seq OWNER TO us;
