CREATE TYPE public.operation_status_enum AS ENUM (
	'scheduled',
	'failed',
	'done'
);

ALTER TYPE public.operation_status_enum OWNER TO us;
