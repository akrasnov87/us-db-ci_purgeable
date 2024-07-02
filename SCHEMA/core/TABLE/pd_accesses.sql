CREATE TABLE core.pd_accesses (
	id smallint DEFAULT nextval('core.auto_id_pd_accesses'::regclass) NOT NULL,
	f_user integer,
	f_role smallint,
	c_name text,
	c_criteria text,
	c_function text,
	c_columns text,
	b_deletable boolean DEFAULT false NOT NULL,
	b_creatable boolean DEFAULT false NOT NULL,
	b_editable boolean DEFAULT false NOT NULL,
	b_full_control boolean DEFAULT false NOT NULL,
	c_created_user text DEFAULT 'iserv'::text NOT NULL,
	d_created_date timestamp without time zone DEFAULT now() NOT NULL,
	c_change_user text,
	d_change_date timestamp without time zone,
	sn_delete boolean DEFAULT false NOT NULL,
	dl_id bigint
);

ALTER TABLE core.pd_accesses OWNER TO us;

COMMENT ON TABLE core.pd_accesses IS 'Права доступа';

COMMENT ON COLUMN core.pd_accesses.id IS 'Идентификатор';

COMMENT ON COLUMN core.pd_accesses.f_user IS 'Пользователь';

COMMENT ON COLUMN core.pd_accesses.f_role IS 'Роль';

COMMENT ON COLUMN core.pd_accesses.c_name IS 'Табл./Предст./Функц.';

COMMENT ON COLUMN core.pd_accesses.c_criteria IS 'Серверный фильтр';

COMMENT ON COLUMN core.pd_accesses.c_function IS 'Функция RPC или её часть';

COMMENT ON COLUMN core.pd_accesses.c_columns IS 'Запрещенные колонки';

COMMENT ON COLUMN core.pd_accesses.b_deletable IS 'Разрешено удалени';

COMMENT ON COLUMN core.pd_accesses.b_creatable IS 'Разрешено создание';

COMMENT ON COLUMN core.pd_accesses.b_editable IS 'Разрешено редактирование';

COMMENT ON COLUMN core.pd_accesses.b_full_control IS 'Дополнительный доступ';

COMMENT ON COLUMN core.pd_accesses.c_created_user IS 'Логин пользователя создавшего запись';

COMMENT ON COLUMN core.pd_accesses.d_created_date IS 'Дата создания записи';

COMMENT ON COLUMN core.pd_accesses.c_change_user IS 'Логин пользователя обновившего запись';

COMMENT ON COLUMN core.pd_accesses.d_change_date IS 'Дата обновления записи';

COMMENT ON COLUMN core.pd_accesses.sn_delete IS 'Признак удаления';

COMMENT ON COLUMN core.pd_accesses.dl_id IS 'Вспомогательное поле для объектов Datalens';

--------------------------------------------------------------------------------

ALTER TABLE core.pd_accesses
	ADD CONSTRAINT pd_accesses_f_role_fkey FOREIGN KEY (f_role) REFERENCES core.pd_roles(id);

--------------------------------------------------------------------------------

ALTER TABLE core.pd_accesses
	ADD CONSTRAINT pd_accesses_f_user_fkey FOREIGN KEY (f_user) REFERENCES core.pd_users(id);

--------------------------------------------------------------------------------

ALTER TABLE core.pd_accesses
	ADD CONSTRAINT pd_accesses_pkey PRIMARY KEY (id);
