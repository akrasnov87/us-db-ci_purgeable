CREATE OR REPLACE FUNCTION public.get_id(OUT result bigint) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
    DECLARE
        our_epoch bigint := 1514754000000;
        seq_id bigint;
        now_millis bigint;
        shard_id int := 1;
    BEGIN
        SELECT nextval('counter_seq') % 4096 INTO seq_id;

        SELECT FLOOR(EXTRACT(EPOCH FROM clock_timestamp()) * 1000) INTO now_millis;
        result := (now_millis - our_epoch) << 23;
        result := result | (shard_id << 10);
        result := result | (seq_id);
    END;
    $$;

ALTER FUNCTION public.get_id(OUT result bigint) OWNER TO us;
