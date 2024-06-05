CREATE OR REPLACE FUNCTION core.sf_users_with_alias(_f_user integer, _alias boolean) RETURNS TABLE(id integer, c_login text, c_claims text, b_disabled boolean, d_created_date timestamp without time zone, d_change_date timestamp without time zone, d_last_auth_date timestamp without time zone, f_avatar uuid, c_email text, c_claims_name text, f_org integer, c_profile text, f_profile integer, c_profile_const text, f_level integer, c_level text, c_intg_host text, f_alias integer, f_original integer)
    LANGUAGE plpgsql
    AS $$
/**
* @params {integer} _f_user - иден. пользователя
*/
BEGIN
	RETURN QUERY 
		SELECT 	CASE
					WHEN _alias THEN coalesce(u.f_alias, u.id)
					ELSE u.id
				END, -- идентификатор пользователя
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
				u.f_avatar, -- ссылка на автарку
				u.c_email, -- email
			    concat('.', ( SELECT string_agg(t.c_description, '.'::text) AS string_agg
			    		FROM ( 	SELECT r.c_description
			    			FROM core.pd_userinroles uir
			                JOIN core.pd_roles r ON uir.f_role = r.id
			              	WHERE uir.f_user = u.id AND uir.sn_delete = false
			              	ORDER BY r.n_weight DESC) t), '.') AS c_claims_name, -- наименование ролей
				u.f_org, -- ссылка на организацию
				p.c_description, -- описание профиля
				p.id, -- идентификатор профиля
				p.c_name, -- константа профиля
				l.id, -- идентификатор уровня
				l.c_name, -- наименование уровня
				u.c_intg_host,
				u.f_alias,
				u.id
		FROM core.pd_users u
		INNER JOIN core.pd_profiles AS p ON p.id = u.f_profile
		LEFT JOIN core.pd_levels AS l ON l.id = u.f_level
		WHERE u.id = _f_user AND u.sn_delete = false;
END;
$$;

ALTER FUNCTION core.sf_users_with_alias(_f_user integer, _alias boolean) OWNER TO us;

COMMENT ON FUNCTION core.sf_users_with_alias(_f_user integer, _alias boolean) IS 'Системная функция. Получение информации о пользователе';
