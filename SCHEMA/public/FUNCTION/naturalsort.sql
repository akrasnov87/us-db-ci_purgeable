CREATE OR REPLACE FUNCTION public.naturalsort(text) RETURNS bytea
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
            SELECT string_agg(
                convert_to(
                    coalesce(
                        r[2],
                        length(length(r[1])::text) || length(r[1])::text || r[1]
                    ),
                    'UTF8'
                ),
                '\x00'
            ) from regexp_matches(
                regexp_replace(
                    regexp_replace($1, 'ё', 'е', 'g'),
                    '_', '!', 'g'
                ),
                '0*([0-9]+)|([^0-9]+)', 'g'
            ) r;
        $_$;

ALTER FUNCTION public.naturalsort(text) OWNER TO us;
