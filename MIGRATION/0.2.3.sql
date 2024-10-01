START TRANSACTION;

-- добавление безопасности   
INSERT INTO core.pd_accesses(f_role, c_name, c_function, b_deletable, b_creatable, b_editable, b_full_control)
VALUES
(2, 'copy', NULL,	false,	true,	false,	false),
(3, 'copy', NULL,	false,	true,	false,	false);

COMMIT TRANSACTION;