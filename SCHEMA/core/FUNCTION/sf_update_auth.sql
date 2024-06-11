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

COMMENT ON FUNCTION core.sf_update_auth(_c_version text, _f_user integer, _n_key integer, _c_ip text, _c_name text, _b_key_mode boolean) IS 'Обновление информации об авторизации';
