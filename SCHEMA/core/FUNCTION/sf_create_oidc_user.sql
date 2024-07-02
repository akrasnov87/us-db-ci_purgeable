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

COMMENT ON FUNCTION core.sf_create_oidc_user(_login text, _token text, _jb_data jsonb) IS 'Создание пользователя авторизовавшегося через OIDC';
