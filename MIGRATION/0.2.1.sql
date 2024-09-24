START TRANSACTION;

CREATE VIEW public.dl_access AS
	SELECT t.user_id,
    t.object_id,
    t.dl_id,
    t.c_login
   FROM ( SELECT DISTINCT u.id AS user_id,
            split_part(a.c_function, '.'::text, 2) AS object_id,
            a.dl_id,
            u.c_login
           FROM ((core.pd_users u
             JOIN core.pd_userinroles uir ON ((uir.f_user = u.id)))
             JOIN core.pd_accesses a ON (((a.f_user = u.id) AND (a.c_function IS NOT NULL))))
          WHERE starts_with(a.c_function, 'DL.'::text)
        UNION
         SELECT DISTINCT u.id AS user_id,
            split_part(a.c_function, '.'::text, 2) AS object_id,
            a.dl_id,
            u.c_login
           FROM ((core.pd_users u
             JOIN core.pd_userinroles uir ON ((uir.f_user = u.id)))
             JOIN core.pd_accesses a ON (((a.f_role = uir.f_role) AND (a.c_function IS NOT NULL))))
          WHERE starts_with(a.c_function, 'DL.'::text)) t;

ALTER VIEW public.dl_access OWNER TO us;

-- добавление безопасности   
INSERT INTO core.pd_accesses(f_role, c_name, c_function, b_deletable, b_creatable, b_editable, b_full_control)
VALUES
(2, 'move-workbooks', NULL,	false,	true,	false,	false),
(3, 'move-workbooks', NULL,	false,	true,	false,	false);

COMMIT TRANSACTION;