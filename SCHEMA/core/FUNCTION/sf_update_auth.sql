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
DECLARE
	_n_new_key 		integer;
BEGIN
	IF _c_version = 'Datalens Embed' THEN
		IF _b_key_mode = TRUE AND (SELECT count(*) FROM core.pd_users AS u WHERE u.id = _f_user AND u.b_key = true) > 0 THEN
			IF (SELECT COUNT(*) FROM core.pd_user_devices as ud WHERE ud.f_user = _f_user AND ud.c_device_name = _c_name AND ud.b_disabled = false) = 0 THEN
				SELECT core.sf_gen_key(_f_user) INTO _n_new_key;

				INSERT INTO core.pd_user_devices(f_user, n_key, c_ip, b_main, c_device_name, c_device_name_uf, b_verify)
				VALUES(_f_user, _n_new_key, _c_ip, false, _c_name, _c_version, true);

				RETURN _n_new_key;
			ELSE
				SELECT ud.n_key INTO _n_new_key 
				FROM core.pd_user_devices as ud WHERE ud.f_user = _f_user AND ud.c_device_name = _c_name AND ud.b_disabled = false
				LIMIT 1;
				
				RETURN _n_new_key;
			END IF;
		ELSE
			RETURN NULL;
		END IF;
	ELSE
		UPDATE core.pd_users AS u 
		SET d_last_auth_date = now(), 
		c_version = _c_version 
		WHERE u.id = _f_user;
	END IF;
	
	IF _b_key_mode = TRUE AND (SELECT count(*) FROM core.pd_users AS u WHERE u.id = _f_user AND u.b_key = true) > 0 THEN
		SELECT core.sf_gen_key(_f_user) INTO _n_new_key;	
		
		IF (SELECT count(*) FROM core.pd_user_devices AS ud WHERE ud.f_user = _f_user AND ud.b_main = TRUE) = 0 THEN
			-- пользователь авторизуется первый раз
			INSERT INTO core.pd_user_devices(f_user, n_key, c_ip, b_main, c_device_name, b_verify)
			VALUES(_f_user, _n_new_key, _c_ip, true, _c_name, true);
		ELSEIF (SELECT count(*) FROM core.pd_user_devices AS ud WHERE ud.f_user = _f_user AND ud.n_key = _n_key) = 1 THEN
			-- пользователь переавторизовывается
			UPDATE core.pd_user_devices AS ud
			SET n_key = _n_new_key,
			d_last_date = now(),
			c_ip = _c_ip,
			b_verify = true,
			c_device_name = _c_name
			WHERE ud.f_user = _f_user AND ud.n_key = _n_key;
		ELSEIF (SELECT count(*) FROM core.pd_user_devices as ud where ud.f_user = _f_user and ud.b_verify = false) = 1 then
			select ud.n_key into _n_new_key from core.pd_user_devices as ud where ud.f_user = _f_user and ud.b_verify = false;
			
			return _n_new_key * -1;
		ELSEIF (select count(*) from core.pd_user_devices as ud where ud.f_user = _f_user and ud.b_main = true) = 1
			 	and (select count(*) from core.pd_user_devices as ud where ud.f_user = _f_user) = 1 then
			select ud.n_key into _n_new_key from core.pd_user_devices as ud where ud.f_user = _f_user and ud.b_main = true;
			
			return _n_new_key * -1;
		else
			RETURN NULL;
		END IF;
		
		RETURN _n_new_key;
	ELSE
		RETURN core.sf_gen_key(_f_user);
	END IF;
END
$$;

ALTER FUNCTION core.sf_update_auth(_c_version text, _f_user integer, _n_key integer, _c_ip text, _c_name text, _b_key_mode boolean) OWNER TO us;

COMMENT ON FUNCTION core.sf_update_auth(_c_version text, _f_user integer, _n_key integer, _c_ip text, _c_name text, _b_key_mode boolean) IS 'Обновление информации об авторизации';
