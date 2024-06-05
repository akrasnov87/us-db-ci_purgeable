CREATE TABLE public.embedding_secrets (
	embedding_secret_id bigint DEFAULT public.get_id() NOT NULL,
	title text NOT NULL,
	workbook_id bigint NOT NULL,
	public_key text NOT NULL,
	created_by text NOT NULL,
	created_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE public.embedding_secrets OWNER TO us;

--------------------------------------------------------------------------------

CREATE INDEX embedding_secrets_workbook_id_idx ON public.embedding_secrets USING btree (workbook_id);

--------------------------------------------------------------------------------

ALTER TABLE public.embedding_secrets
	ADD CONSTRAINT embedding_secrets_pkey PRIMARY KEY (embedding_secret_id);

--------------------------------------------------------------------------------

ALTER TABLE public.embedding_secrets
	ADD CONSTRAINT embedding_secrets_workbook_id_fkey FOREIGN KEY (workbook_id) REFERENCES public.workbooks(workbook_id) ON UPDATE CASCADE ON DELETE CASCADE;
