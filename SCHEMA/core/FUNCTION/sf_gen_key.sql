CREATE OR REPLACE FUNCTION core.sf_gen_key(_f_user integer) RETURNS integer
    LANGUAGE plpgsql STABLE
    AS $$
/**
 * @params _f_user {integer} - иден. пользователя
 * @params _n_key {integer} - предыдущий ключ безопасности
 *
 * @returns {integer} ключ безопасности
 */
DECLARE
	_n_new_key 		integer;
	_b_key			boolean;
	_n_max_number	integer = 99999000;
	_n_min_key		integer;
	_b_exists		boolean;
BEGIN
	SELECT u.b_key INTO _b_key 
	FROM core.pd_users AS u
	WHERE u.id = _f_user;
	
	IF _b_key THEN
		-- плохой способ уменьшить вероятность получения одинакового ключа
		SELECT t.t INTO _n_new_key 
		FROM random_in_range(10000000, _n_max_number) AS t;	
		
		SELECT COUNT(*) > 0 INTO _b_exists
		FROM core.pd_user_devices AS ud
		WHERE ud.f_user = _f_user AND ud.n_key = _n_new_key;
		
		SELECT MIN(ud.n_key) INTO _n_min_key
		FROM core.pd_user_devices AS ud
		WHERE ud.f_user = _f_user;
		
		IF _b_exists THEN
			PERFORM core.sf_write_log('Был создан ключ, который уже привязан к устройству.', _n_new_key::text, 0);
			SELECT t.t INTO _n_new_key 
			FROM random_in_range(1, _n_min_key) AS t;
		END IF;
	ELSE
		RETURN _f_user;
	END IF;
	
	RETURN _n_new_key;
END
$$;

ALTER FUNCTION core.sf_gen_key(_f_user integer) OWNER TO us;

COMMENT ON FUNCTION core.sf_gen_key(_f_user integer) IS 'Генерация ключа безопасности';
