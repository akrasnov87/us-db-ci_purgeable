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

ALTER FUNCTION core.sf_update_pwd(_login text, _password text, _new_password text) OWNER TO us;

COMMENT ON FUNCTION core.sf_update_pwd(_login text, _password text, _new_password text) IS 'Замена пароля пользователя';
