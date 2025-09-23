CREATE TYPE public.entity_bindings_target_type AS ENUM (
	'entries',
	'workbooks'
);

ALTER TYPE public.entity_bindings_target_type OWNER TO "pg-user";
