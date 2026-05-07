CREATE TYPE public.subscription_recipient_transport_type_enum AS ENUM (
	'email',
	'tg'
);

ALTER TYPE public.subscription_recipient_transport_type_enum OWNER TO "pg-user";
