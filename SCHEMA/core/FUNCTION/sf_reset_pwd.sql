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

COMMENT ON FUNCTION core.sf_reset_pwd(_login text, _new_password text) IS 'Сброс пароля пользователя';
