CREATE OR REPLACE FUNCTION core.sf_create_user(_login text, _password text, _email text, _claims json, _project_name text) RETURNS TABLE(msg text, user_id integer, n_code integer)
    LANGUAGE plpgsql ROWS 1
    AS $$
/**
	Создание пользователя
	
	_login: text 		- логин
	_password: text 	- пароль
 	_email: text 		- адрес эл. почты
 	_claims: json 		- роли в формате json, например ["master", "datalens"]
	_project_name: text - проект по умолчанию
 * 
 * @returns {integer} - иден. пользователя
 */
DECLARE
	_f_user 					integer;
BEGIN
	
	-- все проверки пройдены
	INSERT INTO core.pd_users(c_login, s_hash, c_email, b_disabled, c_project_name)
	VALUES (_login, public.crypt(_password, public.gen_salt('bf')), _email, false, _project_name) RETURNING id INTO _f_user;
	
	PERFORM core.pf_update_user_roles(_f_user, _claims);
	
	RETURN QUERY SELECT '', _f_user, 0;
END
$$;

ALTER FUNCTION core.sf_create_user(_login text, _password text, _email text, _claims json, _project_name text) OWNER TO us;

COMMENT ON FUNCTION core.sf_create_user(_login text, _password text, _email text, _claims json, _project_name text) IS 'Создание пользователя';
