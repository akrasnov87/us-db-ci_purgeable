SET TIMEZONE TO 'UTC';

SET check_function_bodies = false;

SET search_path = pg_catalog;

ALTER TABLE core.pd_user_devices
	DROP CONSTRAINT "core.pd_user_devices_pkey";

ALTER TABLE core.pd_user_devices
	DROP CONSTRAINT pd_user_devices_f_user_fkey;

DROP FUNCTION core.sf_gen_key(_f_user integer);

DROP FUNCTION core.sf_user_devices(_f_user integer, _n_key integer);

-- DEPCY: This FUNCTION depends on the TABLE: core.pd_user_devices

CREATE OR REPLACE FUNCTION core.sf_verify_user(_login text, _password text, _c_ip text, _c_name text, _n_key integer, _b_key_mode boolean) RETURNS integer
    LANGUAGE plpgsql
    AS $$
/**
 * @params {text} _login - логин
 * @params {text} _password - пароль
 * @params {text} _c_ip - IP-адрес
 * @params {integer} _n_key - ключ
 * @params {boolean} _b_key_mode - рижим авторизации по ключу
 * 
 * @returns {integer} - иден. пользователя
 */
DECLARE
	_f_user_without_device	integer;
	_d_expired_date			date;

	_embed_id				bigint;
BEGIN
	IF _login = 'datalens_embedding' THEN
		-- авторизация через "Поделиться"
		SELECT 	SPLIT_PART(CONVERT_FROM(DECODE(es.public_key, 'BASE64'), 'UTF-8'), ':', 1), 
				SPLIT_PART(CONVERT_FROM(DECODE(es.public_key, 'BASE64'), 'UTF-8'), ':', 2) INTO _login, _password
		FROM public.embeds AS e
		INNER JOIN public.embedding_secrets AS es ON e.embedding_secret_id = es.embedding_secret_id
		WHERE e.embed_id = _password::bigint;
	END IF;
	
	-- проверяем блокировку
	SELECT u.d_expired_date INTO _d_expired_date 
	FROM core.pd_users AS u 
	WHERE u.c_login = _login;
	
	IF _d_expired_date IS NOT NULL AND NOW() > _d_expired_date THEN
		UPDATE core.pd_users AS u
		SET b_disabled = true
		WHERE u.c_login = _login;
		
		RETURN null;
	END IF;

	-- читаем информацию из БД без учёта устройств
	SELECT (CASE WHEN t.b_verify THEN t.id ELSE -1 END) INTO _f_user_without_device FROM (SELECT 
		CASE WHEN u.s_hash IS NULL 
			THEN u.c_password = _password 
			ELSE public.crypt(_password, u.s_hash) = u.s_hash 
		END AS b_verify,
		u.id
	FROM core.pd_users AS u 
	WHERE u.c_login = _login AND u.b_disabled = false AND u.sn_delete = false) AS t;

	RETURN _f_user_without_device;
END
$$;

-- DEPCY: This FUNCTION depends on the TABLE: core.pd_user_devices

CREATE OR REPLACE FUNCTION core.sf_update_auth(_c_version text, _f_user integer, _n_key integer, _c_ip text, _c_name text, _b_key_mode boolean) RETURNS integer
    LANGUAGE plpgsql
    AS $$
/**
 * @params {text} _c_version - версия
 * @params {integer} _f_user - идентификатор пользователя
 * @params {integer} _n_key - ключ доступа
 * @params {text} _c_ip - IP-адрес
 * @params {text} _c_name - имя устройства
 * @params {boolean} _b_key_mode - режим доступа через ключ
 * 
 * @returns {integer} - новый ключ доступа
 */
BEGIN
	UPDATE core.pd_users AS u 
	SET d_last_auth_date = now()
	WHERE u.id = _f_user;
		
	RETURN _f_user;
END
$$;

DROP TABLE core.pd_user_devices;

CREATE OR REPLACE FUNCTION core.of_users(sender jsonb, params jsonb) RETURNS TABLE(id integer, c_login text, c_claims text, b_disabled boolean, d_created_date timestamp without time zone, d_change_date timestamp without time zone, d_last_auth_date timestamp without time zone, c_email text, c_claims_name text, jb_data jsonb)
    LANGUAGE plpgsql
    AS $$

/**
    Получение списка пользователей

    @params {jsonb} sender - информация о текущем пользователей
    @params {jsonb} params - параметры фильтрации
 */
BEGIN
    RETURN QUERY
        SELECT  u.id, -- идентификатор пользователя
                u.c_login, -- логин
                concat('.', ( SELECT string_agg(t.c_name, '.'::text) AS string_agg
                       FROM ( SELECT r.c_name
                               FROM core.pd_userinroles uir
                                 JOIN core.pd_roles r ON uir.f_role = r.id
                              WHERE uir.f_user = u.id AND uir.sn_delete = false
                              ORDER BY r.n_weight DESC) t), '.') AS c_claims, -- список ролей, где разделителем является точка
                u.b_disabled,               -- признак активности
                u.d_created_date,           -- дата создания
                u.d_change_date,            -- дата модификации
                u.d_last_auth_date,         -- дата последней авторизации
                u.c_email,                                                                      -- email
                concat('.', ( SELECT string_agg(t.c_description, '.'::text) AS string_agg
                        FROM (  SELECT r.c_description
                            FROM core.pd_userinroles uir
                            JOIN core.pd_roles r ON uir.f_role = r.id
                            WHERE uir.f_user = u.id AND uir.sn_delete = false
                            ORDER BY r.n_weight DESC) t), '.') AS c_claims_name,                -- название ролей
                u.jb_data 
        FROM core.pd_users AS u;
END;
$$;

ALTER FUNCTION core.of_users(sender jsonb, params jsonb) OWNER TO us;

COMMENT ON FUNCTION core.of_users(sender jsonb, params jsonb) IS 'Получение списка пользователей';

CREATE OR REPLACE FUNCTION core.sf_create_embed(_public_key text, _entity_id bigint, _created_by text, _reject text) RETURNS TABLE(decode_id bigint, encode_id text, existsing boolean)
    LANGUAGE plpgsql ROWS 1
    AS $$
DECLARE
	_embedding_secret_id			bigint;
	_embed_id						bigint;
	_workbook_id					bigint;
	_existsing						boolean = false;
BEGIN
	SELECT public.get_id() INTO _embedding_secret_id;
	SELECT public.get_id() INTO _embed_id;

	SELECT e.workbook_id INTO _workbook_id
	FROM public.entries AS e 
	WHERE e.entry_id = _entity_id;

	IF lower(_reject) = 'true' THEN
		-- удаляем старую ссылку
		DELETE FROM public.embeds AS e 
		WHERE e.entry_id = _entity_id AND e.created_by = _created_by;
	END IF;

	IF (SELECT COUNT(*) FROM public.embeds AS e WHERE e.entry_id = _entity_id AND e.created_by = _created_by) = 0 THEN
		-- создаём embedding_secret
		INSERT INTO public.embedding_secrets(
		embedding_secret_id, title, workbook_id, public_key, created_by, created_at)
		VALUES (_embedding_secret_id, public.encode_id(_embedding_secret_id), _workbook_id, _public_key, _created_by, now());
	
		INSERT INTO public.embeds(
		embed_id, title, embedding_secret_id, entry_id, deps_ids, unsigned_params, created_by, created_at)
		VALUES (_embed_id, public.encode_id(_embed_id), _embedding_secret_id, _entity_id, '{}', '{}', _created_by, now());
	ELSE
		SELECT true INTO _existsing;

		-- достаём ранее созданный
		SELECT e.embed_id INTO _embed_id
		FROM public.embeds AS e
		WHERE e.entry_id = _entity_id AND e.created_by = _created_by;
	END IF;

	RETURN QUERY
		SELECT _embed_id, public.encode_id(_embed_id), _existsing;
END
$$;

ALTER FUNCTION core.sf_create_embed(_public_key text, _entity_id bigint, _created_by text, _reject text) OWNER TO us;

COMMENT ON FUNCTION core.sf_create_embed(_public_key text, _entity_id bigint, _created_by text, _reject text) IS 'Создание ссылки для "Поделиться"';

COMMENT ON FUNCTION core.pf_accesses(n_user_id integer) IS 'Системная функция. Получение прав доступа для пользователя. Используется "vaccine-node"JS';

CREATE OR REPLACE FUNCTION core.sf_reset_pwd(_login text, _new_password text) RETURNS text
    LANGUAGE plpgsql
    AS $$
/** 
	Сброс пароля пользователя
	
	login: text 		- логин
	_new_password: text - пароль
 */
DECLARE
	_is_hash 	boolean;
BEGIN
	SELECT u.s_hash IS NOT NULL INTO _is_hash
	FROM core.pd_users AS u 
	WHERE u.c_login = _login AND u.sn_delete = false;
	
	IF _is_hash THEN
		UPDATE core.pd_users AS u
		SET s_hash = public.crypt(_new_password, public.gen_salt('bf')),
		c_password = null,
		d_change_date = now()
		WHERE u.c_login = _login;

		RETURN (SELECT 	u.c_email 
		FROM core.pd_users AS u 
		WHERE u.c_login = _login);
	ELSE
		UPDATE core.pd_users AS u
		SET c_password = _new_password,
		s_hash = null,
		d_change_date = now()
		WHERE u.c_login = _login;

		RETURN (SELECT 	u.c_email 
		FROM core.pd_users AS u 
		WHERE u.c_login = _login);
	END IF;
END
$$;

CREATE OR REPLACE FUNCTION core.sf_update_pwd(_login text, _password text, _new_password text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
/**
 * @params {text} _login - логин
 * @params {text} _password - пароль
 * @params {text} _new_password - новый пароль
 * 
 * @returns {boolean} - иден. пользователя
 */
DECLARE
	_b_verify boolean;
	_b_hash boolean;
BEGIN
	
	SELECT 
		CASE WHEN u.s_hash is NULL 
			THEN u.c_password = _password 
			ELSE public.crypt(_password, u.s_hash) = u.s_hash 
		END, u.s_hash IS NOT NULL INTO _b_verify, _b_hash
	FROM core.pd_users AS u WHERE u.c_login = _login AND u.b_disabled = false AND u.sn_delete = false;
	
	IF _b_verify THEN 
		IF _b_hash THEN
			UPDATE core.pd_users AS u
			SET s_hash = public.crypt(_new_password, public.gen_salt('bf')),
			c_password = null,
			d_change_date = now()
			WHERE u.c_login = _login;
			
			RETURN TRUE;
		ELSE
			UPDATE core.pd_users AS u
			SET c_password = _new_password,
			s_hash = null,
			d_change_date = now()
			WHERE u.c_login = _login;
			
			RETURN TRUE;
		END IF;
	END IF;
	
	RETURN FALSE;
END
$$;