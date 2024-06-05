CREATE TABLE core.pd_users (
	id integer DEFAULT nextval('core.auto_id_pd_users'::regclass) NOT NULL,
	c_login text NOT NULL,
	c_password text,
	s_hash text,
	c_email text,
	jb_data jsonb,
	d_last_auth_date timestamp without time zone,
	d_last_change_password timestamp without time zone,
	b_key boolean DEFAULT true NOT NULL,
	b_disabled boolean DEFAULT false NOT NULL,
	d_created_date timestamp without time zone DEFAULT now(),
	c_created_user text DEFAULT 'iserv'::text NOT NULL,
	d_change_date timestamp without time zone,
	c_change_user text,
	sn_delete boolean DEFAULT false NOT NULL
);

ALTER TABLE core.pd_users OWNER TO us;

COMMENT ON TABLE core.pd_users IS 'Пользователи / Организации';

COMMENT ON COLUMN core.pd_users.id IS 'Идентификатор';

COMMENT ON COLUMN core.pd_users.c_login IS 'Логин';

COMMENT ON COLUMN core.pd_users.c_password IS 'Пароль';

COMMENT ON COLUMN core.pd_users.s_hash IS 'Hash';

COMMENT ON COLUMN core.pd_users.c_email IS 'Адрес электронной почты';

COMMENT ON COLUMN core.pd_users.d_last_auth_date IS 'Дата последней авторизации';

COMMENT ON COLUMN core.pd_users.d_last_change_password IS 'Дата изменения пароля';

COMMENT ON COLUMN core.pd_users.b_key IS 'Используется доступ по ключу';

COMMENT ON COLUMN core.pd_users.b_disabled IS 'Отключен';

COMMENT ON COLUMN core.pd_users.d_created_date IS 'Дата создания записи';

COMMENT ON COLUMN core.pd_users.c_created_user IS 'Логин пользователья создавшего запись';

COMMENT ON COLUMN core.pd_users.d_change_date IS 'Дата обновления записи';

COMMENT ON COLUMN core.pd_users.c_change_user IS 'Логин пользователья изменившего запись';

COMMENT ON COLUMN core.pd_users.sn_delete IS 'Удален';

--------------------------------------------------------------------------------

CREATE INDEX pd_users_b_disabled_sn_delete_idx ON core.pd_users USING btree (b_disabled, sn_delete);

--------------------------------------------------------------------------------

ALTER TABLE core.pd_users
	ADD CONSTRAINT pd_users_pkey PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE core.pd_users
	ADD CONSTRAINT pd_users_uniq_c_login UNIQUE (c_login);
