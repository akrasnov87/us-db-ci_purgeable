CREATE TABLE public.comments (
	id uuid DEFAULT public.uuid_generate_v1mc() NOT NULL,
	feed text NOT NULL,
	creator_login text NOT NULL,
	created_date timestamp(0) with time zone DEFAULT now(),
	modifier_login text,
	modified_date timestamp(0) with time zone,
	date timestamp(0) with time zone NOT NULL,
	date_until timestamp(0) with time zone,
	type public.comment_type NOT NULL,
	text text NOT NULL,
	meta jsonb NOT NULL,
	params jsonb,
	is_removed boolean DEFAULT false,
	removed_date timestamp(0) with time zone,
	remover_login text
);

ALTER TABLE public.comments OWNER TO us;

--------------------------------------------------------------------------------

CREATE INDEX comments_is_removed_feed_date_date_until_idx ON public.comments USING btree (is_removed, feed, date, date_until);

--------------------------------------------------------------------------------

ALTER TABLE public.comments
	ADD CONSTRAINT comments_pkey PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.comments
	ADD CONSTRAINT date_until_after_date CHECK (((date_until IS NULL) OR (date_until >= date)));

--------------------------------------------------------------------------------

ALTER TABLE public.comments
	ADD CONSTRAINT is_removed_with_removed_date_with_remover_login CHECK ((((NOT is_removed) AND (removed_date IS NULL) AND (remover_login IS NULL)) OR (is_removed AND (removed_date IS NOT NULL) AND (remover_login IS NOT NULL))));

--------------------------------------------------------------------------------

ALTER TABLE public.comments
	ADD CONSTRAINT modified_date_after_created_date CHECK (((modified_date IS NULL) OR (modified_date > created_date)));

--------------------------------------------------------------------------------

ALTER TABLE public.comments
	ADD CONSTRAINT modifier_login_with_modified_date CHECK ((((modifier_login IS NULL) AND (modified_date IS NULL)) OR ((modifier_login IS NOT NULL) AND (modified_date IS NOT NULL))));
