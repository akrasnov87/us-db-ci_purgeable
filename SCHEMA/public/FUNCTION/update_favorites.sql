CREATE OR REPLACE FUNCTION public.update_favorites() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            BEGIN
                NEW.sort_alias := naturalsort(NEW.alias);
                RETURN NEW;
            END
        $$;

ALTER FUNCTION public.update_favorites() OWNER TO us;
