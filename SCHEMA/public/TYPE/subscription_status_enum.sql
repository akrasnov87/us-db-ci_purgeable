CREATE TYPE public.subscription_status_enum AS ENUM (
	'active',
	'stopped',
	'suspended'
);

ALTER TYPE public.subscription_status_enum OWNER TO "pg-user";
