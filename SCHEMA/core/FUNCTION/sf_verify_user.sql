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

COMMENT ON FUNCTION core.sf_verify_user(_login text, _password text, _c_ip text, _c_name text, _n_key integer, _b_key_mode boolean) IS 'Проверка пользователя на авторизацию';
