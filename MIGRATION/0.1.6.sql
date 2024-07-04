SET TIMEZONE TO 'UTC';

SET check_function_bodies = false;

START TRANSACTION;

SET search_path = pg_catalog;

CREATE SCHEMA IF NOT EXISTS core;

ALTER SCHEMA core OWNER TO us;

CREATE SEQUENCE IF NOT EXISTS core.auto_id_pd_accesses
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE core.auto_id_pd_accesses OWNER TO us;

CREATE SEQUENCE IF NOT EXISTS core.auto_id_pd_roles
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE core.auto_id_pd_roles OWNER TO us;

CREATE SEQUENCE IF NOT EXISTS core.auto_id_pd_userinroles
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE core.auto_id_pd_userinroles OWNER TO us;

CREATE SEQUENCE IF NOT EXISTS core.auto_id_pd_users
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE core.auto_id_pd_users OWNER TO us;

-- DEPCY: This SEQUENCE is a dependency of COLUMN: core.pd_projects.id

CREATE SEQUENCE IF NOT EXISTS core.pd_projects_id_seq
	AS integer
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE core.pd_projects_id_seq OWNER TO us;

CREATE TABLE IF NOT EXISTS core.pd_projects (
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

-- DEPCY: This SEQUENCE is a dependency of COLUMN: core.sd_logs.id

CREATE SEQUENCE IF NOT EXISTS core.sd_logs_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE core.sd_logs_id_seq OWNER TO us;

CREATE TABLE IF NOT EXISTS core.sd_logs (
	id bigint DEFAULT nextval('core.sd_logs_id_seq'::regclass) NOT NULL,
	d_date date NOT NULL,
	jb_data jsonb NOT NULL,
	d_time time without time zone NOT NULL
);

ALTER TABLE core.sd_logs OWNER TO us;

CREATE TABLE IF NOT EXISTS core.pd_accesses (
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

CREATE TABLE IF NOT EXISTS core.pd_roles (
	id integer DEFAULT nextval('core.auto_id_pd_roles'::regclass) NOT NULL,
	c_name text NOT NULL,
	c_description text,
	n_weight integer DEFAULT 0 NOT NULL,
	b_base boolean DEFAULT false NOT NULL,
	d_created_date timestamp without time zone DEFAULT now() NOT NULL,
	c_created_user text DEFAULT 'iserv'::text NOT NULL,
	d_change_date timestamp without time zone,
	c_change_user text,
	sn_delete boolean DEFAULT false NOT NULL
);

ALTER TABLE core.pd_roles OWNER TO us;

CREATE TABLE IF NOT EXISTS core.pd_userinroles (
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

CREATE TABLE IF NOT EXISTS core.pd_users (
	id integer DEFAULT nextval('core.auto_id_pd_users'::regclass) NOT NULL,
	c_login text NOT NULL,
	c_password text,
	s_hash text,
	c_email text,
	c_project_name text,
	jb_data jsonb,
	d_last_auth_date timestamp without time zone,
	d_last_change_password timestamp without time zone,
	b_key boolean DEFAULT false NOT NULL,
	b_disabled boolean DEFAULT false NOT NULL,
	d_created_date timestamp without time zone DEFAULT now(),
	c_created_user text DEFAULT 'iserv'::text NOT NULL,
	d_change_date timestamp without time zone,
	c_change_user text,
	sn_delete boolean DEFAULT false NOT NULL,
	d_expired_date timestamp without time zone,
	b_oidc boolean
);

ALTER TABLE core.pd_users OWNER TO us;

CREATE OR REPLACE FUNCTION core.of_users(sender jsonb, params jsonb) RETURNS TABLE(id integer, c_login text, c_claims text, b_disabled boolean, d_created_date timestamp without time zone, d_change_date timestamp without time zone, d_last_auth_date timestamp without time zone, c_email text, c_project_name text, b_oidc boolean, c_claims_name text, b_base boolean, jb_data jsonb)
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
                CASE WHEN u.c_project_name IS NULL THEN (SELECT p.c_name FROM core.pd_projects AS p WHERE p.b_base LIMIT 1) ELSE u.c_project_name END,
                u.b_oidc,
                concat('.', ( SELECT string_agg(t.c_description, '.'::text) AS string_agg
                        FROM (  SELECT r.c_description
                            FROM core.pd_userinroles uir
                            JOIN core.pd_roles r ON uir.f_role = r.id
                            WHERE uir.f_user = u.id AND uir.sn_delete = false
                            ORDER BY r.n_weight DESC) t), '.') AS c_claims_name,                -- название ролей
				CASE WHEN u.c_login = 'master' THEN true ELSE false END,
                u.jb_data 
        FROM core.pd_users AS u
		WHERE CASE WHEN params#>>'{filter}' IS NULL THEN 1=1 ELSE u.c_login ilike ('%' || (params#>>'{filter}')::text || '%') END
		ORDER BY u.c_login;
END;
$$;

ALTER FUNCTION core.of_users(sender jsonb, params jsonb) OWNER TO us;

CREATE OR REPLACE FUNCTION core.pf_accesses(n_user_id integer) RETURNS TABLE(table_name text, record_criteria text, rpc_function text, column_name text, is_editable boolean, is_deletable boolean, is_creatable boolean, is_fullcontrol boolean, access integer)
    LANGUAGE plpgsql
    AS $$
/**
* @params {integer} n_user_id - иден. пользователя
*/
BEGIN
	RETURN QUERY 
		SELECT * FROM (SELECT 
	        a.c_name,
	        a.c_criteria,
	        a.c_function,
	        a.c_columns,
	        a.b_editable, 
	        a.b_deletable, 
	        a.b_creatable, 
	        a.b_full_control, 
	        core.sf_accesses(r.c_name, u.id, u.c_claims, a.f_user) AS access 
	    FROM core.pd_accesses AS a
	    LEFT JOIN core.sf_users_with_alias(n_user_id, false) AS u ON n_user_id = u.id
	    LEFT JOIN core.pd_roles AS r ON a.f_role = r.id
	    WHERE a.sn_delete = false) AS t 
		WHERE t.access > 0;
END;
$$;

ALTER FUNCTION core.pf_accesses(n_user_id integer) OWNER TO us;

CREATE OR REPLACE FUNCTION core.pf_update_user_roles(_user_id integer, _claims json) RETURNS integer
    LANGUAGE plpgsql
    AS $$
/**
* @params {bigint} _user_id - идент. пользователя
* @params {json} _claims - роли в виде строки '["manager", "inspector"]'
*
* @returns {bigint} идент. пользователя
*/
BEGIN
	delete from core.pd_userinroles
	where f_user = _user_id;

	insert into core.pd_userinroles(f_user, f_role, sn_delete, c_created_user)
	SELECT _user_id, (select id from core.pd_roles where t.value = c_name), false, 'iserv'
	FROM json_array_elements_text(_claims) as t;
	
	RETURN _user_id;
END
$$;

ALTER FUNCTION core.pf_update_user_roles(_user_id integer, _claims json) OWNER TO us;

CREATE OR REPLACE FUNCTION core.sf_accesses(c_role_name text, n_currentuser integer, c_claims text, n_user_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
/**
* @params {text} c_role_name - имя роли в безопасности
* @params {integer} n_currentuser - идент. пользователя в безопасности
* @params {text} c_claims - список ролей
* @params {integer} n_user_id - иден. пользователя
* 
* @returns
* 0 - доступ запрещен
*/
BEGIN
    IF c_role_name is null and n_user_id is null then
		RETURN 1;
	ELSEIF (c_role_name is not null and c_claims is not null and POSITION(CONCAT('.', c_role_name, '.') IN c_claims) > 0) then
		RETURN 2;
	ELSEIF (c_role_name is not null and c_claims is not null and POSITION(CONCAT('.', c_role_name, '.') IN c_claims) > 0) then  
		RETURN 3;
	ELSEIF (c_role_name is null and n_currentuser = n_user_id) then
        RETURN 4;
    ELSEIF (c_role_name = 'anonymous' or n_user_id = -1) then
		RETURN 5;
	else
		RETURN 0;
	end if;
 END
$$;

ALTER FUNCTION core.sf_accesses(c_role_name text, n_currentuser integer, c_claims text, n_user_id integer) OWNER TO us;

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

CREATE OR REPLACE FUNCTION core.sf_create_oidc_user(_login text, _token text, _jb_data jsonb) RETURNS TABLE(msg text, user_id integer, n_code integer)
    LANGUAGE plpgsql ROWS 1
    AS $$
/**
	Создание пользователя
	
	_login: text 		- логин
	_token: text 		- токен
 * 
 * @returns {integer} - иден. пользователя
 */
DECLARE
	_f_user 					integer;
BEGIN
	
	INSERT INTO core.pd_users(c_login, c_password, b_disabled, b_oidc, jb_data)
	VALUES (_login, _token, false, true, _jb_data) RETURNING id INTO _f_user;
	
	PERFORM core.pf_update_user_roles(_f_user, '["oidc", "datalens"]');
	
	RETURN QUERY 
		SELECT '', _f_user, 0;
END
$$;

ALTER FUNCTION core.sf_create_oidc_user(_login text, _token text, _jb_data jsonb) OWNER TO us;

CREATE OR REPLACE FUNCTION core.sf_create_user(_login text, _password text, _email text, _claims json) RETURNS TABLE(msg text, user_id integer, n_code integer)
    LANGUAGE plpgsql ROWS 1
    AS $$
/**
	Создание пользователя
	
	_login: text 		- логин
	_password: text 	- пароль
 	_email: text 		- адрес эл. почты
 	_claims: json 		- роли в формате json, например ["master", "datalens"]
 * 
 * @returns {integer} - иден. пользователя
 */
DECLARE
	_f_user 					integer;
BEGIN
	
	-- все проверки пройдены
	INSERT INTO core.pd_users(c_login, s_hash, c_email, b_disabled)
	VALUES (_login, public.crypt(_password, public.gen_salt('bf')), _email, false) RETURNING id INTO _f_user;
	
	PERFORM core.pf_update_user_roles(_f_user, _claims);
	
	RETURN QUERY SELECT '', _f_user, 0;
END
$$;

ALTER FUNCTION core.sf_create_user(_login text, _password text, _email text, _claims json) OWNER TO us;

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
		d_change_date = now(),
		d_last_change_password = now()
		WHERE u.c_login = _login;

		RETURN (SELECT 	u.c_email 
		FROM core.pd_users AS u 
		WHERE u.c_login = _login);
	ELSE
		UPDATE core.pd_users AS u
		SET c_password = _new_password,
		s_hash = null,
		d_change_date = now(),
		d_last_change_password = now()
		WHERE u.c_login = _login;

		RETURN (SELECT 	u.c_email 
		FROM core.pd_users AS u 
		WHERE u.c_login = _login);
	END IF;
END
$$;

ALTER FUNCTION core.sf_reset_pwd(_login text, _new_password text) OWNER TO us;

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

ALTER FUNCTION core.sf_update_auth(_c_version text, _f_user integer, _n_key integer, _c_ip text, _c_name text, _b_key_mode boolean) OWNER TO us;

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
			d_change_date = now(),
			d_last_change_password = now()
			WHERE u.c_login = _login;
			
			RETURN TRUE;
		ELSE
			UPDATE core.pd_users AS u
			SET c_password = _new_password,
			s_hash = null,
			d_change_date = now(),
			d_last_change_password = now()
			WHERE u.c_login = _login;
			
			RETURN TRUE;
		END IF;
	END IF;
	
	RETURN FALSE;
END
$$;

ALTER FUNCTION core.sf_update_pwd(_login text, _password text, _new_password text) OWNER TO us;

CREATE OR REPLACE FUNCTION core.sf_users(_f_user integer) RETURNS TABLE(id integer, c_login text, c_claims text, b_disabled boolean, d_created_date timestamp without time zone, d_change_date timestamp without time zone, d_last_auth_date timestamp without time zone, c_email text, c_project_name text, b_oidc boolean, username text, c_claims_name text)
    LANGUAGE plpgsql
    AS $$
/**
* @params {integer} _f_user - иден. пользователя
*/
BEGIN
	RETURN QUERY 
		SELECT	* FROM core.sf_users_with_alias(_f_user, true);
END;
$$;

ALTER FUNCTION core.sf_users(_f_user integer) OWNER TO us;

CREATE OR REPLACE FUNCTION core.sf_users_by_login_with_alias(_c_login text, _alias boolean) RETURNS TABLE(id integer, c_login text, c_claims text, b_disabled boolean, d_created_date timestamp without time zone, d_change_date timestamp without time zone, d_last_auth_date timestamp without time zone, c_email text, c_project_name text, b_oidc boolean, username text, c_claims_name text)
    LANGUAGE plpgsql
    AS $$
/**
* @params {integer} _c_login - иден. пользователя
*/

DECLARE
	_f_user			integer;
BEGIN
	SELECT u.id INTO _f_user
	FROM core.pd_users AS u
	WHERE u.c_login = _c_login;

	RETURN QUERY 
		SELECT * 
		FROM core.sf_users_with_alias(_f_user, _alias);
END;
$$;

ALTER FUNCTION core.sf_users_by_login_with_alias(_c_login text, _alias boolean) OWNER TO us;

CREATE OR REPLACE FUNCTION core.sf_users_with_alias(_f_user integer, _alias boolean) RETURNS TABLE(id integer, c_login text, c_claims text, b_disabled boolean, d_created_date timestamp without time zone, d_change_date timestamp without time zone, d_last_auth_date timestamp without time zone, c_email text, c_project_name text, b_oidc boolean, username text, c_claims_name text)
    LANGUAGE plpgsql
    AS $$
/**
* @params {integer} _f_user - иден. пользователя
*/
BEGIN
	RETURN QUERY 
		SELECT 	u.id, -- идентификатор пользователя
				u.c_login, -- логин пользователя
			    concat('.', ( SELECT string_agg(t.c_name, '.'::text) AS string_agg
			           FROM ( SELECT r.c_name
			                   FROM core.pd_userinroles uir
			                     JOIN core.pd_roles r ON uir.f_role = r.id
			                  WHERE uir.f_user = u.id AND uir.sn_delete = false
			                  ORDER BY r.n_weight DESC) t), '.') AS c_claims, -- список ролей разделённых точкой
			    u.b_disabled, -- признак активности
				u.d_created_date, -- дата создания УЗ
				u.d_change_date, -- дата модификации УЗ
				u.d_last_auth_date, -- дата последней авторизации
				u.c_email, -- email
				u.c_project_name,
				u.b_oidc,
				u.jb_data#>>'{name}' AS username,
			    concat('.', ( SELECT string_agg(t.c_description, '.'::text) AS string_agg
			    		FROM ( 	SELECT r.c_description
			    			FROM core.pd_userinroles uir
			                JOIN core.pd_roles r ON uir.f_role = r.id
			              	WHERE uir.f_user = u.id AND uir.sn_delete = false
			              	ORDER BY r.n_weight DESC) t), '.') AS c_claims_name -- наименование ролей
		FROM core.pd_users u
		WHERE u.id = _f_user AND u.sn_delete = false;
END;
$$;

ALTER FUNCTION core.sf_users_with_alias(_f_user integer, _alias boolean) OWNER TO us;

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

ALTER FUNCTION core.sf_verify_user(_login text, _password text, _c_ip text, _c_name text, _n_key integer, _b_key_mode boolean) OWNER TO us;

CREATE OR REPLACE FUNCTION public.random_in_range(integer, integer) RETURNS integer
    LANGUAGE sql
    AS $_$
    SELECT floor(($1 + ($2 - $1 + 1) * random()))::INTEGER;
$_$;

ALTER FUNCTION public.random_in_range(integer, integer) OWNER TO us;

CREATE INDEX IF NOT EXISTS pd_users_b_disabled_sn_delete_idx ON core.pd_users USING btree (b_disabled, sn_delete);

CREATE INDEX IF NOT EXISTS sd_logs_d_date_idx ON core.sd_logs USING btree (d_date);

-- DEPCY: This CONSTRAINT is a dependency of CONSTRAINT: core.pd_accesses.pd_accesses_f_role_fkey

ALTER TABLE core.pd_roles
	ADD CONSTRAINT pd_roles_pkey PRIMARY KEY (id);

ALTER TABLE core.pd_accesses
	ADD CONSTRAINT pd_accesses_f_role_fkey FOREIGN KEY (f_role) REFERENCES core.pd_roles(id);

-- DEPCY: This CONSTRAINT is a dependency of CONSTRAINT: core.pd_accesses.pd_accesses_f_user_fkey

ALTER TABLE core.pd_users
	ADD CONSTRAINT pd_users_pkey PRIMARY KEY (id);

ALTER TABLE core.pd_accesses
	ADD CONSTRAINT pd_accesses_f_user_fkey FOREIGN KEY (f_user) REFERENCES core.pd_users(id);

ALTER TABLE core.pd_accesses
	ADD CONSTRAINT pd_accesses_pkey PRIMARY KEY (id);

ALTER TABLE core.pd_projects
	ADD CONSTRAINT pd_projects_pkey PRIMARY KEY (id);

ALTER TABLE core.pd_projects
	ADD CONSTRAINT pd_projects_uniq_c_name UNIQUE (c_name);

ALTER TABLE core.pd_roles
	ADD CONSTRAINT pd_roles_uniq_c_name UNIQUE (c_name);

ALTER TABLE core.pd_userinroles
	ADD CONSTRAINT pd_userinroles_f_role_fkey FOREIGN KEY (f_role) REFERENCES core.pd_roles(id);

ALTER TABLE core.pd_userinroles
	ADD CONSTRAINT pd_userinroles_f_user_fkey FOREIGN KEY (f_user) REFERENCES core.pd_users(id);

ALTER TABLE core.pd_userinroles
	ADD CONSTRAINT pd_userinroles_pkey PRIMARY KEY (id);

ALTER TABLE core.pd_users
	ADD CONSTRAINT pd_users_uniq_c_login UNIQUE (c_login);

ALTER TABLE core.sd_logs
	ADD CONSTRAINT sd_rpc_log_pkey PRIMARY KEY (id);

CREATE VIEW core.sv_objects AS
	SELECT table1.table_name,
    table1.table_type,
    table1.table_title,
    table1.primary_key,
    table1.table_comment,
    table1.table_schema
   FROM ( SELECT (t.table_name)::character varying AS table_name,
            (t.table_type)::character varying AS table_type,
            (pgd.description)::character varying AS table_title,
            (cc.column_name)::character varying AS primary_key,
            ''::character varying AS table_comment,
            t.table_schema
           FROM ((((information_schema.tables t
             LEFT JOIN pg_statio_all_tables st ON ((st.relname = (t.table_name)::name)))
             LEFT JOIN pg_description pgd ON (((pgd.objoid = st.relid) AND (pgd.objsubid = 0))))
             LEFT JOIN information_schema.table_constraints tc ON ((((t.table_name)::text = (tc.table_name)::text) AND ((t.table_catalog)::text = (tc.table_catalog)::text))))
             LEFT JOIN information_schema.constraint_column_usage cc ON (((tc.constraint_name)::text = (cc.constraint_name)::text)))
          WHERE (((t.table_catalog)::text = (current_database())::text) AND ((tc.constraint_type)::text = 'PRIMARY KEY'::text))
        UNION
         SELECT (t.table_name)::character varying AS table_name,
            (t.table_type)::character varying AS table_type,
            (pgd.description)::character varying AS table_title,
            ''::character varying AS primary_key,
            ''::character varying AS table_comment,
            t.table_schema
           FROM ((information_schema.tables t
             LEFT JOIN pg_class pgc ON ((pgc.relname = (t.table_name)::name)))
             LEFT JOIN pg_description pgd ON ((pgd.objoid = pgc.oid)))
          WHERE (((t.table_type)::text = 'VIEW'::text) AND ((t.table_catalog)::text = (current_database())::text))
        UNION
         SELECT (r.routine_name)::character varying AS table_name,
            (r.routine_type)::character varying AS table_type,
            (pgd.description)::character varying AS table_title,
            ''::character varying AS primary_key,
            ''::character varying AS table_comment,
            r.routine_schema AS table_schema
           FROM ((information_schema.routines r
             LEFT JOIN pg_proc pgp ON ((pgp.proname = (r.routine_name)::name)))
             LEFT JOIN pg_description pgd ON ((pgd.objoid = pgp.oid)))
          WHERE ((r.routine_catalog)::text = (current_database())::text)) table1
  WHERE (((table1.table_schema)::text <> 'pg_catalog'::text) AND ((table1.table_schema)::text <> 'information_schema'::text) AND ((table1.table_schema)::text <> 'public'::text));

ALTER VIEW core.sv_objects OWNER TO us;

CREATE VIEW public.dl_access AS
	SELECT t.user_id,
    t.object_id,
    t.dl_id,
    t.c_login
   FROM ( SELECT DISTINCT u.id AS user_id,
            split_part(a.c_function, '.'::text, 2) AS object_id,
            a.dl_id,
            u.c_login
           FROM ((core.pd_users u
             JOIN core.pd_userinroles uir ON ((uir.f_user = u.id)))
             JOIN core.pd_accesses a ON (((a.f_user = u.id) AND (a.c_function IS NOT NULL))))
          WHERE starts_with(a.c_function, 'DL.'::text)
        UNION ALL
         SELECT DISTINCT u.id AS user_id,
            split_part(a.c_function, '.'::text, 2) AS object_id,
            a.dl_id,
            u.c_login
           FROM ((core.pd_users u
             JOIN core.pd_userinroles uir ON ((uir.f_user = u.id)))
             JOIN core.pd_accesses a ON (((a.f_role = uir.f_role) AND (a.c_function IS NOT NULL))))
          WHERE starts_with(a.c_function, 'DL.'::text)) t;

ALTER VIEW public.dl_access OWNER TO us;

ALTER SEQUENCE core.pd_projects_id_seq
	OWNED BY core.pd_projects.id;

ALTER SEQUENCE core.sd_logs_id_seq
	OWNED BY core.sd_logs.id;

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

COMMENT ON TABLE core.pd_userinroles IS 'Пользователи в ролях';

COMMENT ON COLUMN core.pd_userinroles.id IS 'Идентификатор';

COMMENT ON COLUMN core.pd_userinroles.f_user IS 'Пользователь';

COMMENT ON COLUMN core.pd_userinroles.f_role IS 'Роль';

COMMENT ON COLUMN core.pd_userinroles.c_created_user IS 'Логин пользователя создавшего запись';

COMMENT ON COLUMN core.pd_userinroles.d_created_date IS 'Дата создания записи';

COMMENT ON COLUMN core.pd_userinroles.c_change_user IS 'Логин пользователя обновившего запись';

COMMENT ON COLUMN core.pd_userinroles.d_change_date IS 'Дата обновления записи';

COMMENT ON COLUMN core.pd_userinroles.sn_delete IS 'Признак удаления';

COMMENT ON TABLE core.pd_users IS 'Пользователи / Организации';

COMMENT ON COLUMN core.pd_users.id IS 'Идентификатор';

COMMENT ON COLUMN core.pd_users.c_login IS 'Логин';

COMMENT ON COLUMN core.pd_users.c_password IS 'Пароль';

COMMENT ON COLUMN core.pd_users.s_hash IS 'Hash';

COMMENT ON COLUMN core.pd_users.c_email IS 'Адрес электронной почты';

COMMENT ON COLUMN core.pd_users.c_project_name IS 'Имя проекта';

COMMENT ON COLUMN core.pd_users.d_last_auth_date IS 'Дата последней авторизации';

COMMENT ON COLUMN core.pd_users.d_last_change_password IS 'Дата изменения пароля';

COMMENT ON COLUMN core.pd_users.b_key IS 'Используется доступ по ключу';

COMMENT ON COLUMN core.pd_users.b_disabled IS 'Отключен';

COMMENT ON COLUMN core.pd_users.d_created_date IS 'Дата создания записи';

COMMENT ON COLUMN core.pd_users.c_created_user IS 'Логин пользователья создавшего запись';

COMMENT ON COLUMN core.pd_users.d_change_date IS 'Дата обновления записи';

COMMENT ON COLUMN core.pd_users.c_change_user IS 'Логин пользователья изменившего запись';

COMMENT ON COLUMN core.pd_users.sn_delete IS 'Удален';

COMMENT ON COLUMN core.pd_users.d_expired_date IS 'Срок действия';

COMMENT ON COLUMN core.pd_users.b_oidc IS 'Признак, что пользователь создан через OIDC';

COMMENT ON FUNCTION core.of_users(sender jsonb, params jsonb) IS 'Получение списка пользователей';

COMMENT ON FUNCTION core.pf_accesses(n_user_id integer) IS 'Системная функция. Получение прав доступа для пользователя. Используется "vaccine-node"JS';

COMMENT ON FUNCTION core.pf_update_user_roles(_user_id integer, _claims json) IS 'Обновление ролей у пользователя';

COMMENT ON FUNCTION core.sf_accesses(c_role_name text, n_currentuser integer, c_claims text, n_user_id integer) IS 'Системная функция для обработки прав. Для внешнего использования не применять';

COMMENT ON FUNCTION core.sf_create_embed(_public_key text, _entity_id bigint, _created_by text, _reject text) IS 'Создание ссылки для "Поделиться"';

COMMENT ON FUNCTION core.sf_create_oidc_user(_login text, _token text, _jb_data jsonb) IS 'Создание пользователя авторизовавшегося через OIDC';

COMMENT ON FUNCTION core.sf_create_user(_login text, _password text, _email text, _claims json) IS 'Создание пользователя';

COMMENT ON FUNCTION core.sf_reset_pwd(_login text, _new_password text) IS 'Сброс пароля пользователя';

COMMENT ON FUNCTION core.sf_update_auth(_c_version text, _f_user integer, _n_key integer, _c_ip text, _c_name text, _b_key_mode boolean) IS 'Обновление информации об авторизации';

COMMENT ON FUNCTION core.sf_update_pwd(_login text, _password text, _new_password text) IS 'Замена пароля пользователя';

COMMENT ON FUNCTION core.sf_users(_f_user integer) IS 'Системная функция. Получение информации о пользователе';

COMMENT ON FUNCTION core.sf_users_by_login_with_alias(_c_login text, _alias boolean) IS 'Системная функция. Получение информации о пользователе';

COMMENT ON FUNCTION core.sf_users_with_alias(_f_user integer, _alias boolean) IS 'Системная функция. Получение информации о пользователе';

COMMENT ON FUNCTION core.sf_verify_user(_login text, _password text, _c_ip text, _c_name text, _n_key integer, _b_key_mode boolean) IS 'Проверка пользователя на авторизацию';

COMMIT TRANSACTION;