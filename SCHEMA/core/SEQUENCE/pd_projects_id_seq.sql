CREATE SEQUENCE core.pd_projects_id_seq
	AS integer
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE core.pd_projects_id_seq OWNER TO us;

ALTER SEQUENCE core.pd_projects_id_seq
	OWNED BY core.pd_projects.id;
