CREATE OR REPLACE FUNCTION core.sf_users_with_alias(_f_user integer, _alias boolean) RETURNS TABLE(id integer, c_login text, c_claims text, b_disabled boolean, d_created_date timestamp without time zone, d_change_date timestamp without time zone, d_last_auth_date timestamp without time zone, c_email text, c_claims_name text)
    LANGUAGE plpgsql
    AS $$
/**
* @params {integer} _f_user - иден. пользователя
*/
BEGIN
	RETURN QUERY 
		SELECT 	u.id, -- идентификатор пользователя
				u.c_login, -- логин пользователя
			    concat('.', ( SELECT string_agg(t.c_name, '.'::text) AS string_agg
			           FROM ( SELECT r.c_name
			                   FROM core.pd_userinroles uir
			                     JOIN core.pd_roles r ON uir.f_role = r.id
			                  WHERE uir.f_user = u.id AND uir.sn_delete = false
			                  ORDER BY r.n_weight DESC) t), '.') AS c_claims, -- список ролей разделённых точкой
			    u.b_disabled, -- признак активности
				u.d_created_date, -- дата создания УЗ
				u.d_change_date, -- дата модификации УЗ
				u.d_last_auth_date, -- дата последней авторизации
				u.c_email, -- email
			    concat('.', ( SELECT string_agg(t.c_description, '.'::text) AS string_agg
			    		FROM ( 	SELECT r.c_description
			    			FROM core.pd_userinroles uir
			                JOIN core.pd_roles r ON uir.f_role = r.id
			              	WHERE uir.f_user = u.id AND uir.sn_delete = false
			              	ORDER BY r.n_weight DESC) t), '.') AS c_claims_name -- наименование ролей
		FROM core.pd_users u
		WHERE u.id = _f_user AND u.sn_delete = false;
END;
$$;

ALTER FUNCTION core.sf_users_with_alias(_f_user integer, _alias boolean) OWNER TO us;

COMMENT ON FUNCTION core.sf_users_with_alias(_f_user integer, _alias boolean) IS 'Системная функция. Получение информации о пользователе';
