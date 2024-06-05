CREATE TABLE public.favorites (
	entry_id bigint NOT NULL,
	tenant_id text NOT NULL,
	login text NOT NULL,
	created_at timestamp with time zone DEFAULT now(),
	alias text,
	display_alias text,
	sort_alias bytea
);

ALTER TABLE public.favorites OWNER TO us;

--------------------------------------------------------------------------------

CREATE INDEX favorites_alias_idx ON public.favorites USING btree (alias);

--------------------------------------------------------------------------------

CREATE INDEX favorites_sort_alias_idx ON public.favorites USING btree (sort_alias);

--------------------------------------------------------------------------------

CREATE INDEX tenant_id_plus_login_idx ON public.favorites USING btree (tenant_id, login);

--------------------------------------------------------------------------------

CREATE TRIGGER before_favorites_insert_or_update
	BEFORE INSERT OR UPDATE ON public.favorites
	FOR EACH ROW
	EXECUTE PROCEDURE public.update_favorites();

--------------------------------------------------------------------------------

ALTER TABLE public.favorites
	ADD CONSTRAINT favorites_entry_id_tenant_id_constraint FOREIGN KEY (entry_id, tenant_id) REFERENCES public.entries(entry_id, tenant_id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.favorites
	ADD CONSTRAINT favorites_pkey PRIMARY KEY (entry_id, login);
