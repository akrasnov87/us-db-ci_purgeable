CREATE OR REPLACE FUNCTION core.sf_users_by_login_with_alias(_c_login text, _alias boolean) RETURNS TABLE(id integer, c_login text, c_claims text, b_disabled boolean, d_created_date timestamp without time zone, d_change_date timestamp without time zone, d_last_auth_date timestamp without time zone, c_email text, c_project_name text, b_oidc boolean, userName text, c_claims_name text)
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

COMMENT ON FUNCTION core.sf_users_by_login_with_alias(_c_login text, _alias boolean) IS 'Системная функция. Получение информации о пользователе';
