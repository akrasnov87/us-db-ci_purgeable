CREATE TABLE core.sd_logs (
	id bigint DEFAULT nextval('core.sd_logs_id_seq'::regclass) NOT NULL,
	d_date date NOT NULL,
	jb_data jsonb NOT NULL,
	d_time time without time zone NOT NULL
);

ALTER TABLE core.sd_logs OWNER TO us;

--------------------------------------------------------------------------------

CREATE INDEX sd_logs_d_date_idx ON core.sd_logs USING btree (d_date);

--------------------------------------------------------------------------------

ALTER TABLE core.sd_logs
	ADD CONSTRAINT sd_rpc_log_pkey PRIMARY KEY (id);
