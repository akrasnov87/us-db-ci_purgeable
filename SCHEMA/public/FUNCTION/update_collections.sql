CREATE OR REPLACE FUNCTION public.update_collections() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            BEGIN
                NEW.sort_title := naturalsort(NEW.title);
                RETURN NEW;
            END
        $$;

ALTER FUNCTION public.update_collections() OWNER TO us;
