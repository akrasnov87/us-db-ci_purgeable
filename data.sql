START TRANSACTION;

-- список ролей
INSERT INTO core.pd_roles(c_name, c_description, n_weight)
VALUES 
('master', 'Мастер', 1000), 
('admin', 'Администратор', 900),	
('datalens', 'Пользователь', 800);

-- первоначальные права доступа
INSERT INTO core.pd_accesses(f_role, c_name, c_function, b_deletable, b_creatable, b_editable, b_full_control)
VALUES
(2, 'embed',NULL,	false,	false,	false,	false),
(2,	'entries',NULL,	false,	true,	false,	false),
(2,	'workbooks',NULL,	false,	true,	false,	false),
(2,	'entries',NULL,	false,	false,	false,	false),
(2,	'breadcrumbs',NULL,	false,	false,	false,	false),
(2,	'collections',NULL,	false,	true,	false,	false),
(2,	'collection-content',NULL,	false,	false,	false,	false),
(2,	'workbook',NULL,	false,	true,	false,	false),
(2,	'collection',NULL,	false,	true,	false,	false),
(2,	'workbookInRoot',NULL,	false,	true,	false,	false),
(2,	'collectionInRoot',NULL,	false,	true,	false,	false),
(2,	'meta',NULL,	false,	false,	false,	false),
(2,	'root-collection-permissions',NULL,	false,	false,	false,	false),
(2,	'update',NULL,	false,	true,	false,	false),
(2,	'rename',NULL,	false,	true,	false,	false),
(2,	'roles',NULL,	false,	false,	false,	false),
(2,	NULL, 'DL.*',	false,	false,	false,	false),
(2,	NULL, 'opensource-demo.*',	false,	false,	false,	false),
(NULL,	NULL, 'DL.datalens.*',	false,	false,	false,	false),
(3,	'embed',NULL,	false,	false,	false,	false),
(3,	'entries',NULL,	false,	false,	false,	false),
(3,	'workbooks',NULL, false,	false,	false,	false),
(3,	'entries',NULL,	false,	false,	false,	false),
(3,	'breadcrumbs',NULL,	false,	false,	false,	false),
(3,	'collections',NULL,	false,	false,	false,	false),
(3,	'collection-content',NULL,	false,	false,	false,	false),
(3,	'workbook',NULL,	false,	false,	false,	false),
(3,	'collection',NULL,	false,	false,	false,	false),
(3,	'workbookInRoot',NULL,	false,	false,	false,	false),
(3,	'collectionInRoot',NULL,	false,	false,	false,	false),
(3,	'meta',NULL,	false,	false,	false,	false),
(3,	'root-collection-permissions',NULL,	false,	false,	false,	false),
(3,	'update',NULL,	false,	false,	false,	false),
(3,	'rename',NULL,	false,	false,	false,	false),
(3,	'roles',NULL,	false,	false,	false,	false);

-- пользователь с максимальными правами
SELECT core.sf_create_user('master', 'qwe-123', '', '["master", "admin"]');

-- администратор
SELECT core.sf_create_user('admin', 'qwe-123', '', '["admin"]');

-- пользователь
SELECT core.sf_create_user('user', 'qwe-123', '', '["datalens"]');

COMMIT TRANSACTION;