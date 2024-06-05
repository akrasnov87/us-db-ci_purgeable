CREATE OR REPLACE FUNCTION public.base36_encode(digits bigint, coding_base character[]) RETURNS character varying
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    DECLARE
        ret varchar;
        val bigint;
    BEGIN
        val := digits;
        ret := '';
        IF val < 0 THEN
            val := val * - 1;
        END IF;
        WHILE val != 0 LOOP
            ret := coding_base [(val % 36)+1] || ret;
            val := val / 36;
        END LOOP;
        RETURN ret;
    END;
    $$;

ALTER FUNCTION public.base36_encode(digits bigint, coding_base character[]) OWNER TO us;
