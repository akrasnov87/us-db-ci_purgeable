CREATE OR REPLACE FUNCTION public.update_workbooks() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            BEGIN
                NEW.sort_title := naturalsort(NEW.title);
                RETURN NEW;
            END
        $$;

ALTER FUNCTION public.update_workbooks() OWNER TO us;
