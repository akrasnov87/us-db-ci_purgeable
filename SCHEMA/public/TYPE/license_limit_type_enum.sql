CREATE TYPE public.license_limit_type_enum AS ENUM (
	'regular',
	'forced'
);

ALTER TYPE public.license_limit_type_enum OWNER TO "pg-user";
