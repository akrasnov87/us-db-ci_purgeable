CREATE VIEW public.analytics_tables_row_count_view AS
	SELECT 'tenants_analytics_view'::text AS view_name,
    count(*) AS row_count
   FROM public.tenants
UNION ALL
 SELECT 'license_limits_analytics_view'::text AS view_name,
    count(*) AS row_count
   FROM public.license_limits
UNION ALL
 SELECT 'licenses_analytics_view'::text AS view_name,
    count(*) AS row_count
   FROM public.licenses;

ALTER VIEW public.analytics_tables_row_count_view OWNER TO "pg-user";
