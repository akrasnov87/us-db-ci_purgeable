CREATE TYPE public.subscription_trigger_type_enum AS ENUM (
	'cron',
	'dataset-refresh',
	'threshold',
	'relative',
	'non-empty',
	'is-true'
);

ALTER TYPE public.subscription_trigger_type_enum OWNER TO "pg-user";
