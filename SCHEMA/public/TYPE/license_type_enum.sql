CREATE TYPE public.license_type_enum AS ENUM (
	'creator',
	'viewer'
);

ALTER TYPE public.license_type_enum OWNER TO "pg-user";
