CREATE TYPE public.workbook_status_enum AS ENUM (
	'active',
	'creating',
	'deleting',
	'deleted'
);

ALTER TYPE public.workbook_status_enum OWNER TO us;
