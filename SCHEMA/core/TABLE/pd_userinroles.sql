CREATE TABLE core.pd_userinroles (
	id integer DEFAULT nextval('core.auto_id_pd_userinroles'::regclass) NOT NULL,
	f_user integer NOT NULL,
	f_role integer NOT NULL,
	c_created_user text DEFAULT 'iserv'::text NOT NULL,
	d_created_date timestamp without time zone DEFAULT now() NOT NULL,
	c_change_user text,
	d_change_date timestamp without time zone,
	sn_delete boolean DEFAULT false
);

ALTER TABLE core.pd_userinroles OWNER TO us;

COMMENT ON TABLE core.pd_userinroles IS 'Пользователи в ролях';

COMMENT ON COLUMN core.pd_userinroles.id IS 'Идентификатор';

COMMENT ON COLUMN core.pd_userinroles.f_user IS 'Пользователь';

COMMENT ON COLUMN core.pd_userinroles.f_role IS 'Роль';

COMMENT ON COLUMN core.pd_userinroles.c_created_user IS 'Логин пользователя создавшего запись';

COMMENT ON COLUMN core.pd_userinroles.d_created_date IS 'Дата создания записи';

COMMENT ON COLUMN core.pd_userinroles.c_change_user IS 'Логин пользователя обновившего запись';

COMMENT ON COLUMN core.pd_userinroles.d_change_date IS 'Дата обновления записи';

COMMENT ON COLUMN core.pd_userinroles.sn_delete IS 'Признак удаления';

--------------------------------------------------------------------------------

ALTER TABLE core.pd_userinroles
	ADD CONSTRAINT pd_userinroles_f_role_fkey FOREIGN KEY (f_role) REFERENCES core.pd_roles(id);

--------------------------------------------------------------------------------

ALTER TABLE core.pd_userinroles
	ADD CONSTRAINT pd_userinroles_f_user_fkey FOREIGN KEY (f_user) REFERENCES core.pd_users(id);

--------------------------------------------------------------------------------

ALTER TABLE core.pd_userinroles
	ADD CONSTRAINT pd_userinroles_pkey PRIMARY KEY (id);
