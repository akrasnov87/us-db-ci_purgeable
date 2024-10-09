CREATE TABLE core.pd_roles (
	id integer DEFAULT nextval('core.auto_id_pd_roles'::regclass) NOT NULL,
	c_name text NOT NULL,
	c_description text,
	n_weight integer DEFAULT 0 NOT NULL,
	b_base boolean DEFAULT false NOT NULL,
	d_created_date timestamp without time zone DEFAULT now() NOT NULL,
	c_created_user text DEFAULT 'iserv'::text NOT NULL,
	d_change_date timestamp without time zone,
	c_change_user text,
	sn_delete boolean DEFAULT false NOT NULL,
	_id text
);

ALTER TABLE core.pd_roles OWNER TO us;

COMMENT ON TABLE core.pd_roles IS 'Роли';

COMMENT ON COLUMN core.pd_roles.id IS 'Идентификатор';

COMMENT ON COLUMN core.pd_roles.c_name IS 'Наименование';

COMMENT ON COLUMN core.pd_roles.c_description IS 'Описание роли';

COMMENT ON COLUMN core.pd_roles.n_weight IS 'Приоритет';

COMMENT ON COLUMN core.pd_roles.b_base IS 'Признак базовой роли';

COMMENT ON COLUMN core.pd_roles.d_created_date IS 'Дата создания записи';

COMMENT ON COLUMN core.pd_roles.c_created_user IS 'Автор создания';

COMMENT ON COLUMN core.pd_roles.d_change_date IS 'Дата обновления записи';

COMMENT ON COLUMN core.pd_roles.c_change_user IS 'Автор изменения';

COMMENT ON COLUMN core.pd_roles.sn_delete IS 'Удален';

--------------------------------------------------------------------------------

ALTER TABLE core.pd_roles
	ADD CONSTRAINT pd_roles_pkey PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE core.pd_roles
	ADD CONSTRAINT pd_roles_uniq_c_name UNIQUE (c_name);
