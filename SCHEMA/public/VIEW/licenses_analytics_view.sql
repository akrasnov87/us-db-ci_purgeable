CREATE VIEW public.licenses_analytics_view AS
	SELECT public.encode_id(license_id) AS license_id,
    tenant_id,
    user_id,
    expires_at,
    created_by,
    created_at
   FROM public.licenses;

ALTER VIEW public.licenses_analytics_view OWNER TO "pg-user";
