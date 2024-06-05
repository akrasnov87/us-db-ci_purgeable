CREATE OR REPLACE FUNCTION public.random_in_range(integer, integer) RETURNS integer
    LANGUAGE sql
    AS $_$
    SELECT floor(($1 + ($2 - $1 + 1) * random()))::INTEGER;
$_$;

ALTER FUNCTION public.random_in_range(integer, integer) OWNER TO us;
