CREATE OR REPLACE FUNCTION core.sf_create_user(_current_user_id integer, _login text, _password text, _email text, _profile_name text, _org_id integer, _level_id integer, level_name text) RETURNS TABLE(msg text, user_id integer, n_code integer)
    LANGUAGE plpgsql ROWS 1
    AS $$
/**
 * @params {integer}	_current_user_id - текущий идентификатор польз., который инициализирует создание
 * @params {text} 		_login - логин
 * @params {text} 		_password - пароль
 * @params {text} 		_email - адрес эл. почты
 * @params {text} 		_profile_name - имя профиля, к оторому будет привязан пользователь
 * @params {integer}	_org_id - идентификатор организации, может быть не указано, если создаётся новый администратор 
 * @params {integer}	_level_id - подразделение, может быть не указано
 * @params {text}		level_name - имя создаваемого подразделения
 * 
 * @returns {integer} - иден. пользователя
 */
DECLARE
	_f_user 					integer;
	_current_level_id			integer;
	_current_profile_weight		integer;
	_create_profile_id			integer;
	_create_profile_weight		integer;
	_claims						json;
BEGIN
	-- получаем максимального вес профиля
	SELECT	MAX(p.n_weight) INTO _current_profile_weight
	FROM core.pd_users AS u
	INNER JOIN core.pd_userinroles AS uir ON uir.f_user = u.id
	INNER JOIN core.pd_roleinprofiles AS rip ON rip.f_role = uir.f_role
	INNER JOIN core.pd_profiles AS p ON p.id = rip.f_profile
	WHERE u.id = _current_user_id;
	
	-- профиль создаваемого пользователя
	SELECT	p.n_weight INTO _create_profile_weight
	FROM core.pd_profiles AS p
	WHERE p.c_name = _profile_name;
	
	SELECT	p.id INTO _create_profile_id
	FROM core.pd_profiles AS p
	WHERE p.c_name = _profile_name;
	
	IF _create_profile_weight IS NULL THEN
		RETURN QUERY SELECT 'Профиль создаваемого пользователя не найден.', -1, 1;
		RETURN;
	END IF;
	
	IF _current_profile_weight IS NULL THEN
		RETURN QUERY SELECT 'Профиль текущего пользователя не найден.', -1, 2;
		RETURN;
	END IF;
	
	IF _create_profile_weight > _current_profile_weight THEN
		RETURN QUERY SELECT 'Профиль создаваемого пользователя имеет больший вес, чем у текущего пользователя.', -1, 3;
		RETURN;
	END IF;
	
	IF _org_id IS NOT NULL AND (SELECT COUNT(*) FROM core.pd_users AS u WHERE u.id = _org_id) = 0 THEN
		RETURN QUERY SELECT 'Родительский пользователь не найден', -1, 4;
		RETURN;
	END IF;
	
	IF _level_id IS NOT NULL AND (SELECT COUNT(*) FROM core.pd_levels AS p WHERE p.id = _level_id) = 0 THEN
		RETURN QUERY SELECT 'Подразделение не найдено', -1, 4;
		RETURN;
	END IF;
	
	-- проверка на возможность закрепления за подразделением
	SELECT u.f_level INTO _current_level_id 
	FROM core.pd_users as u
	WHERE u.id = _current_user_id;
	
	IF _level_id IS NOT NULL AND _current_level_id IS NOT NULL AND (SELECT COUNT(*) FROM core.sf_child_levels(_current_level_id) AS cl WHERE cl.id = _level_id) = 0 THEN
		RETURN QUERY SELECT 'Текущее подразделение пользователя не позволяет привязать подразделение к новому пользователю.', -1, 5;
		RETURN;
	END IF;
	
	IF _level_id IS NULL AND _current_level_id IS NOT NULL AND level_name IS NULL THEN
		RETURN QUERY SELECT 'Подразделение для нового пользователя не указано.', -1, 6;
		RETURN;
	END IF;
	
	-- все проверки пройдены
	INSERT INTO core.pd_users(c_login, s_hash, f_profile, f_org, f_level, c_email, b_disabled)
	VALUES (_login, crypt(_password, gen_salt('bf')), _create_profile_id, _org_id, _level_id::integer, _email, false) RETURNING id INTO _f_user;
	
	-- создаём корневое подразделенние
	IF level_name IS NOT NULL THEN
		INSERT INTO core.pd_levels(f_parent, c_name, b_disabled, c_created_user, d_created_date, f_org, n_code)
		VALUES ((SELECT l.id FROM core.pd_levels AS l WHERE l.f_parent IS NULL LIMIT 1), level_name, false, _login, now(), _f_user, _f_user) 
		RETURNING id INTO _level_id;
		
		UPDATE core.pd_users AS u
		SET f_level = _level_id
		WHERE u.id = _f_user;
	END IF;
	
	IF _org_id IS NULL THEN
		UPDATE core.pd_users AS u
		SET f_org = _f_user
		WHERE u.id = _f_user;
	END IF;
	
	SELECT 	json_agg(r.c_name) INTO _claims
	FROM core.pd_roleinprofiles AS rip
	INNER JOIN core.pd_roles AS r ON r.id = rip.f_role
	WHERE rip.f_profile = _create_profile_id;
	
	PERFORM core.pf_update_user_roles(_f_user, _claims);
	
	-- создание подписок на уведомления по умолчанию
	INSERT INTO core.pd_notify_subscribes(f_type, f_category, f_user, b_disabled)
	SELECT nt.id, nc.id,  _f_user, false
	FROM core.pd_notify_categories AS nc
	CROSS JOIN core.pd_notify_types AS nt -- каждый с каждым
	WHERE nc.b_disabled = false AND nt.b_disabled = false AND nt.b_default = true AND nc.b_default = true AND (	nc.f_role IS NULL OR 	( 	-- создаваемый пользователь в одной из указанных ролей
																SELECT COUNT(*)
																FROM core.pd_roleinprofiles AS rip
																INNER JOIN core.pd_roles AS r ON r.id = rip.f_role
																WHERE rip.f_profile = _create_profile_id AND r.id = nc.f_role
															) > 0
								  );
	
	RETURN QUERY SELECT '', _f_user, 0;
END
$$;

ALTER FUNCTION core.sf_create_user(_current_user_id integer, _login text, _password text, _email text, _profile_name text, _org_id integer, _level_id integer, level_name text) OWNER TO us;

COMMENT ON FUNCTION core.sf_create_user(_current_user_id integer, _login text, _password text, _email text, _profile_name text, _org_id integer, _level_id integer, level_name text) IS 'Создание пользователя';
