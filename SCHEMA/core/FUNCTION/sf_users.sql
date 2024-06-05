CREATE OR REPLACE FUNCTION core.sf_users(_f_user integer) RETURNS TABLE(id integer, c_login text, c_claims text, b_disabled boolean, d_created_date timestamp without time zone, d_change_date timestamp without time zone, d_last_auth_date timestamp without time zone, c_email text, c_claims_name text)
    LANGUAGE plpgsql
    AS $$
/**
* @params {integer} _f_user - иден. пользователя
*/
BEGIN
	RETURN QUERY 
		SELECT	* FROM core.sf_users_with_alias(_f_user, true);
END;
$$;

ALTER FUNCTION core.sf_users(_f_user integer) OWNER TO us;

COMMENT ON FUNCTION core.sf_users(_f_user integer) IS 'Системная функция. Получение информации о пользователе';
