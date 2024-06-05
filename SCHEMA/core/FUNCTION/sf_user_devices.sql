CREATE OR REPLACE FUNCTION core.sf_user_devices(_f_user integer, _n_key integer) RETURNS TABLE(f_user integer, c_device_name text, c_device_name_uf text, c_ip text)
    LANGUAGE plpgsql ROWS 100
    AS $$
/**
	_f_user: integer - идентификатор пользователя
	_n_key: integer - ключ, может быть null
*/
BEGIN
	RETURN QUERY 
		SELECT	ud.f_user,
				ud.c_device_name,
				ud.c_device_name_uf,
				ud.c_ip
		FROM core.pd_user_devices AS ud
		WHERE ud.f_user = _f_user 
			AND ud.b_verify = true
			AND _n_key = ud.n_key
		;
		
END;
$$;

ALTER FUNCTION core.sf_user_devices(_f_user integer, _n_key integer) OWNER TO us;

COMMENT ON FUNCTION core.sf_user_devices(_f_user integer, _n_key integer) IS 'Системная функция. Получение информации об устройствах пользователя';
