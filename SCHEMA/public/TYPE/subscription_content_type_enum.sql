CREATE TYPE public.subscription_content_type_enum AS ENUM (
	'dash',
	'chart',
	'report'
);

ALTER TYPE public.subscription_content_type_enum OWNER TO "pg-user";
