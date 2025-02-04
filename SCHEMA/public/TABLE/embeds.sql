CREATE TABLE public.embeds (
	embed_id bigint DEFAULT public.get_id() NOT NULL,
	title text NOT NULL,
	embedding_secret_id bigint NOT NULL,
	entry_id bigint NOT NULL,
	deps_ids text[] DEFAULT '{}'::text[] NOT NULL,
	unsigned_params text[] DEFAULT '{}'::text[] NOT NULL,
	created_by text NOT NULL,
	created_at timestamp with time zone DEFAULT now() NOT NULL,
	private_params text[] DEFAULT '{}'::text[] NOT NULL,
	public_params_mode boolean DEFAULT true NOT NULL,
	updated_by text NOT NULL,
	updated_at timestamp with time zone DEFAULT now() NOT NULL,
	settings jsonb DEFAULT '{}'::jsonb
);

ALTER TABLE public.embeds OWNER TO us;

--------------------------------------------------------------------------------

CREATE INDEX embeds_embedding_secret_id_idx ON public.embeds USING btree (embedding_secret_id);

--------------------------------------------------------------------------------

CREATE INDEX embeds_entry_id_idx ON public.embeds USING btree (entry_id);

--------------------------------------------------------------------------------

CREATE INDEX embeds_updated_at_idx ON public.embeds USING btree (updated_at);

--------------------------------------------------------------------------------

ALTER TABLE public.embeds
	ADD CONSTRAINT embeds_embedding_secret_id_fkey FOREIGN KEY (embedding_secret_id) REFERENCES public.embedding_secrets(embedding_secret_id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.embeds
	ADD CONSTRAINT embeds_entry_id_fkey FOREIGN KEY (entry_id) REFERENCES public.entries(entry_id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.embeds
	ADD CONSTRAINT embeds_pkey PRIMARY KEY (embed_id);
