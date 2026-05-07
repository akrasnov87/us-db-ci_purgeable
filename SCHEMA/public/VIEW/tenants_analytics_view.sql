CREATE VIEW public.tenants_analytics_view AS
	SELECT tenant_id,
    created_at,
    billing_instance_service_id,
    billing_instance_service_is_active,
    billing_instance_service_updated_at,
    trial_ended_at,
    trial_without_billing,
    billing_discount,
    settings
   FROM public.tenants;

ALTER VIEW public.tenants_analytics_view OWNER TO "pg-user";
