CREATE OR REPLACE FUNCTION core.sf_reset_pwd(_login text, _new_password text, _f_org integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
/** 
 * @params {text} _login - логин
 * @params {text} _new_password - пароль
 * @params {integer} _f_org - иден. родительского пользователя
 * 
 * @returns {boolean} - результат обработки
 */
DECLARE
	_is_hash 	boolean;
BEGIN
	SELECT u.s_hash IS NOT NULL INTO _is_hash
	FROM core.pd_users AS u 
	WHERE u.c_login = _login AND u.sn_delete = false;
	
	IF _is_hash THEN
		UPDATE core.pd_users AS u
		SET s_hash = crypt(_new_password, gen_salt('bf')),
		c_password = null
		WHERE u.c_login = _login AND CASE WHEN _f_org IS NULL THEN 1=1 ELSE u.f_org = _f_org END;

		RETURN (SELECT 	u.c_email 
		FROM core.pd_users AS u 
		WHERE u.c_login = _login AND CASE WHEN _f_org IS NULL THEN 1=1 ELSE u.f_org = _f_org END);
	ELSE
		UPDATE core.pd_users AS u
		SET c_password = _new_password,
		s_hash = null
		WHERE u.c_login = _login AND CASE WHEN _f_org IS NULL THEN 1=1 ELSE u.f_org = _f_org END;

		RETURN (SELECT 	u.c_email 
		FROM core.pd_users AS u 
		WHERE u.c_login = _login AND CASE WHEN _f_org IS NULL THEN 1=1 ELSE u.f_org = _f_org END);
	END IF;
END
$$;

ALTER FUNCTION core.sf_reset_pwd(_login text, _new_password text, _f_org integer) OWNER TO us;

COMMENT ON FUNCTION core.sf_reset_pwd(_login text, _new_password text, _f_org integer) IS 'Сброс пароля пользователя';
