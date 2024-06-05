CREATE OR REPLACE FUNCTION core.sf_accesses(c_role_name text, n_currentuser integer, c_claims text, n_user_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
/**
* @params {text} c_role_name - имя роли в безопасности
* @params {integer} n_currentuser - идент. пользователя в безопасности
* @params {text} c_claims - список ролей
* @params {integer} n_user_id - иден. пользователя
* 
* @returns
* 0 - доступ запрещен
*/
BEGIN
    IF c_role_name is null and n_user_id is null then
		RETURN 1;
	ELSEIF (c_role_name is not null and c_claims is not null and POSITION(CONCAT('.', c_role_name, '.') IN c_claims) > 0) then
		RETURN 2;
	ELSEIF (c_role_name is not null and c_claims is not null and POSITION(CONCAT('.', c_role_name, '.') IN c_claims) > 0) then  
		RETURN 3;
	ELSEIF (c_role_name is null and n_currentuser = n_user_id) then
        RETURN 4;
    ELSEIF (c_role_name = 'anonymous' or n_user_id = -1) then
		RETURN 5;
	else
		RETURN 0;
	end if;
 END
$$;

ALTER FUNCTION core.sf_accesses(c_role_name text, n_currentuser integer, c_claims text, n_user_id integer) OWNER TO us;

COMMENT ON FUNCTION core.sf_accesses(c_role_name text, n_currentuser integer, c_claims text, n_user_id integer) IS 'Системная функция для обработки прав. Для внешнего использования не применять';
