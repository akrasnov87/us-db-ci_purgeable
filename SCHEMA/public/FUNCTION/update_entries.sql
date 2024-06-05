CREATE OR REPLACE FUNCTION public.update_entries() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
        DECLARE
          key TEXT;
        BEGIN
          key := NEW.key;

          NEW.name := SUBSTRING(key FROM '([^/]*)/?$');
          NEW.sort_name := naturalsort(NEW.name);

          RETURN NEW;
        END
        $_$;

ALTER FUNCTION public.update_entries() OWNER TO us;
