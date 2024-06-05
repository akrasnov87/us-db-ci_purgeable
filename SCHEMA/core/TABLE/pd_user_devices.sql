CREATE TABLE core.pd_user_devices (
	id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
	f_user integer NOT NULL,
	c_device_name text DEFAULT 'unknown'::text NOT NULL,
	c_device_name_uf text DEFAULT 'Неизвестное устройство'::text,
	n_key integer,
	c_ip text NOT NULL,
	b_disabled boolean DEFAULT false NOT NULL,
	d_last_date timestamp without time zone DEFAULT now() NOT NULL,
	dx_created timestamp without time zone DEFAULT now() NOT NULL,
	b_main boolean DEFAULT false NOT NULL,
	b_verify boolean DEFAULT false NOT NULL
);

ALTER TABLE core.pd_user_devices OWNER TO us;

COMMENT ON TABLE core.pd_user_devices IS 'Список авторизованных устройств';

COMMENT ON COLUMN core.pd_user_devices.id IS 'Идентификатор';

COMMENT ON COLUMN core.pd_user_devices.f_user IS 'Пользователь';

COMMENT ON COLUMN core.pd_user_devices.c_device_name IS 'Системное имя';

COMMENT ON COLUMN core.pd_user_devices.c_device_name_uf IS 'Пользовательское имя';

COMMENT ON COLUMN core.pd_user_devices.n_key IS 'Ключ';

COMMENT ON COLUMN core.pd_user_devices.c_ip IS 'IP адрес';

COMMENT ON COLUMN core.pd_user_devices.b_disabled IS 'Отключено';

COMMENT ON COLUMN core.pd_user_devices.d_last_date IS 'Последняя дата входа';

COMMENT ON COLUMN core.pd_user_devices.dx_created IS 'Дата создания';

COMMENT ON COLUMN core.pd_user_devices.b_main IS 'Признак главного устройства, нужнодля восстановления авторизации';

COMMENT ON COLUMN core.pd_user_devices.b_verify IS 'Проверка пройдена. Первичный ключ был подтверждён';

--------------------------------------------------------------------------------

ALTER TABLE core.pd_user_devices
	ADD CONSTRAINT "core.pd_user_devices_pkey" PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE core.pd_user_devices
	ADD CONSTRAINT pd_user_devices_f_user_fkey FOREIGN KEY (f_user) REFERENCES core.pd_users(id);
