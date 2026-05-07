CREATE TYPE public.subscription_artifact_type_enum AS ENUM (
	'png'
);

ALTER TYPE public.subscription_artifact_type_enum OWNER TO "pg-user";
