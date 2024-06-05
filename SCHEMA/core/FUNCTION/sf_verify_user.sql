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
	_f_user_with_device		integer;
	_n_new_key				integer;
	_b_key					boolean;
	_d_expired_date			date;
BEGIN
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

	IF _password IS NOT NULL THEN
		-- читаем информацию из БД без учёта устройств
		SELECT (CASE WHEN t.b_verify THEN t.id ELSE -1 END), t.b_key INTO _f_user_without_device, _b_key FROM (SELECT 
			CASE WHEN u.s_hash IS NULL 
				THEN u.c_password = _password 
				ELSE crypt(_password, u.s_hash) = u.s_hash 
			END AS b_verify,
			u.id,
			u.b_key
		FROM core.pd_users AS u 
		WHERE u.c_login = _login AND u.b_disabled = false AND u.sn_delete = false) AS t;
	ELSE
		SELECT NULL INTO _f_user_without_device;
		SELECT true INTO _b_key;
	END IF;

	--raise notice 'f_user_without_device: %', _f_user_without_device;

	IF _b_key_mode = true AND _b_key = true THEN
		-- мы здесь потому, что выполняется провека по ключу
		SELECT u.id INTO _f_user_with_device
		FROM core.pd_users AS u 
		LEFT JOIN core.pd_user_devices AS ud ON u.id = ud.f_user AND ud.b_disabled = false																	   
		WHERE u.c_login = _login AND u.b_disabled = false 
		AND CASE WHEN u.b_key THEN ud.n_key = _n_key ELSE 1=1 END 
		AND u.sn_delete = false
		LIMIT 1;
		
		--raise notice 'f_user_with_device: %', _f_user_with_device;
					
		IF _f_user_without_device IS NULL THEN
			SELECT _f_user_with_device INTO _f_user_without_device;
		END IF;
		
		IF _f_user_with_device IS NULL THEN	
			SELECT core.sf_gen_key(_f_user_without_device) INTO _n_new_key;
			
			-- пользователь авторизуется первый раз
			IF (SELECT count(*) FROM core.pd_user_devices AS ud WHERE ud.f_user = _f_user_without_device AND ud.b_main = true) = 0 THEN
				-- нет главного пользователя
				IF _n_key IS NOT NULL THEN
					INSERT INTO core.pd_user_devices(f_user, c_device_name, n_key, c_ip, b_main, b_verify)
					VALUES(_f_user_without_device, _c_name, _n_new_key, _c_ip, true, true);
				END IF;
			ELSEIF (select count(*) from core.pd_user_devices as ud where ud.f_user = _f_user_without_device and ud.b_verify = false) = 0 then
				-- нет обычного устройства "неизвестное"
				INSERT INTO core.pd_user_devices(f_user, c_device_name, n_key, c_ip)
				VALUES(_f_user_without_device, _c_name, _n_new_key, _c_ip);
				
				IF _n_key IS NOT NULL THEN
					SELECT NULL INTO _f_user_without_device;
				END IF;
			ELSE
				-- обновляем обычное устройство
				UPDATE core.pd_user_devices as ud
				SET c_ip = _c_ip,
				dx_created = now(),
				c_device_name = _c_name
				WHERE ud.f_user = _f_user_without_device AND ud.b_main = false AND ud.b_verify = false;
				
				IF _n_key IS NOT NULL THEN
					SELECT NULL INTO _f_user_without_device;
				END IF;
			END IF;
		END IF;
	END IF;
	
	RETURN _f_user_without_device;
END
$$;

ALTER FUNCTION core.sf_verify_user(_login text, _password text, _c_ip text, _c_name text, _n_key integer, _b_key_mode boolean) OWNER TO us;

COMMENT ON FUNCTION core.sf_verify_user(_login text, _password text, _c_ip text, _c_name text, _n_key integer, _b_key_mode boolean) IS 'Проверка пользователя на авторизацию';
