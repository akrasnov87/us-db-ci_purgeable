CREATE TYPE public.comment_type AS ENUM (
	'flag-x',
	'line-x',
	'band-x',
	'dot-x-y'
);

ALTER TYPE public.comment_type OWNER TO us;
