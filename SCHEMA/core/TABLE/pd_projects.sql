CREATE TABLE core.pd_projects (
	id integer DEFAULT nextval('core.pd_projects_id_seq'::regclass) NOT NULL,
	c_name text NOT NULL,
	c_description text,
	b_base boolean DEFAULT false NOT NULL,
	d_created_date timestamp without time zone DEFAULT now() NOT NULL,
	c_created_user text DEFAULT 'iserv'::text NOT NULL,
	d_change_date timestamp without time zone,
	c_change_user text,
	sn_delete boolean DEFAULT false NOT NULL
);

ALTER TABLE core.pd_projects OWNER TO us;

COMMENT ON TABLE core.pd_projects IS 'Проекты';

COMMENT ON COLUMN core.pd_projects.id IS 'Идентификатор';

COMMENT ON COLUMN core.pd_projects.c_name IS 'Наименование';

COMMENT ON COLUMN core.pd_projects.c_description IS 'Описание';

COMMENT ON COLUMN core.pd_projects.b_base IS 'Признак базового проект';

COMMENT ON COLUMN core.pd_projects.d_created_date IS 'Дата создания записи';

COMMENT ON COLUMN core.pd_projects.c_created_user IS 'Автор создания';

COMMENT ON COLUMN core.pd_projects.d_change_date IS 'Дата обновления записи';

COMMENT ON COLUMN core.pd_projects.c_change_user IS 'Автор изменения';

COMMENT ON COLUMN core.pd_projects.sn_delete IS 'Удален';

--------------------------------------------------------------------------------

ALTER TABLE core.pd_projects
	ADD CONSTRAINT pd_projects_pkey PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE core.pd_projects
	ADD CONSTRAINT pd_projects_uniq_c_name UNIQUE (c_name);
