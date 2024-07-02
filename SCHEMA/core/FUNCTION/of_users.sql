CREATE OR REPLACE FUNCTION core.of_users(sender jsonb, params jsonb) RETURNS TABLE(id integer, c_login text, c_claims text, b_disabled boolean, d_created_date timestamp without time zone, d_change_date timestamp without time zone, d_last_auth_date timestamp without time zone, c_email text, c_project_name text, c_claims_name text, b_oidc boolean, jb_data jsonb)
    LANGUAGE plpgsql
    AS $$

/**
    Получение списка пользователей

    @params {jsonb} sender - информация о текущем пользователей
    @params {jsonb} params - параметры фильтрации
 */
BEGIN
    RETURN QUERY
        SELECT  u.id, -- идентификатор пользователя
                u.c_login, -- логин
                concat('.', ( SELECT string_agg(t.c_name, '.'::text) AS string_agg
                       FROM ( SELECT r.c_name
                               FROM core.pd_userinroles uir
                                 JOIN core.pd_roles r ON uir.f_role = r.id
                              WHERE uir.f_user = u.id AND uir.sn_delete = false
                              ORDER BY r.n_weight DESC) t), '.') AS c_claims, -- список ролей, где разделителем является точка
                u.b_disabled,               -- признак активности
                u.d_created_date,           -- дата создания
                u.d_change_date,            -- дата модификации
                u.d_last_auth_date,         -- дата последней авторизации
                u.c_email,                                                                      -- email
                u.c_project_name,
                u.b_oidc,
                concat('.', ( SELECT string_agg(t.c_description, '.'::text) AS string_agg
                        FROM (  SELECT r.c_description
                            FROM core.pd_userinroles uir
                            JOIN core.pd_roles r ON uir.f_role = r.id
                            WHERE uir.f_user = u.id AND uir.sn_delete = false
                            ORDER BY r.n_weight DESC) t), '.') AS c_claims_name,                -- название ролей
                u.jb_data 
        FROM core.pd_users AS u;
END;
$$;

ALTER FUNCTION core.of_users(sender jsonb, params jsonb) OWNER TO us;

COMMENT ON FUNCTION core.of_users(sender jsonb, params jsonb) IS 'Получение списка пользователей';
