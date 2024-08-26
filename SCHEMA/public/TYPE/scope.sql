CREATE TYPE public.scope AS ENUM (
	'dataset',
	'pdf',
	'folder',
	'dash',
	'connection',
	'widget',
	'config',
	'presentation'
);

ALTER TYPE public.scope OWNER TO us;
