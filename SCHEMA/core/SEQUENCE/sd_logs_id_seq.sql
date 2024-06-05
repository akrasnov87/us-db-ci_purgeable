CREATE SEQUENCE core.sd_logs_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE core.sd_logs_id_seq OWNER TO us;

ALTER SEQUENCE core.sd_logs_id_seq
	OWNED BY core.sd_logs.id;
