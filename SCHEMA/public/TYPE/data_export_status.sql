CREATE TYPE public.data_export_status AS ENUM (
	'IN_PROGRESS',
	'CANCELLED',
	'FINISHED',
	'FAILED'
);

ALTER TYPE public.data_export_status OWNER TO "pg-user";
