CREATE TABLE public.subscription_recipients (
	subscription_id bigint NOT NULL,
	user_id text NOT NULL,
	transport public.subscription_recipient_transport_type_enum NOT NULL,
	created_by text NOT NULL,
	created_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE public.subscription_recipients OWNER TO "pg-user";

--------------------------------------------------------------------------------

CREATE INDEX subscription_recipients_user_id_transport_idx ON public.subscription_recipients USING btree (user_id, transport);

--------------------------------------------------------------------------------

ALTER TABLE public.subscription_recipients
	ADD CONSTRAINT subscription_recipients_pkey PRIMARY KEY (subscription_id, user_id, transport);

--------------------------------------------------------------------------------

ALTER TABLE public.subscription_recipients
	ADD CONSTRAINT subscription_recipients_subscription_id_fkey FOREIGN KEY (subscription_id) REFERENCES public.subscriptions(subscription_id) ON UPDATE CASCADE ON DELETE CASCADE;
