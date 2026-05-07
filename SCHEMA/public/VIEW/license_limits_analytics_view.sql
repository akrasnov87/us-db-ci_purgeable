CREATE VIEW public.license_limits_analytics_view AS
	SELECT public.encode_id(license_limit_id) AS license_limit_id,
    tenant_id,
    type,
    started_at,
    creators_limit_value
   FROM public.license_limits;

ALTER VIEW public.license_limits_analytics_view OWNER TO "pg-user";
