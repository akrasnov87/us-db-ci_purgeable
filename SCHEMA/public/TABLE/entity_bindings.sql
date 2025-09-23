CREATE TABLE public.entity_bindings (
	source_id bigint NOT NULL,
	target_id bigint NOT NULL,
	target_type public.entity_bindings_target_type NOT NULL,
	is_delegated boolean DEFAULT false NOT NULL,
	created_by text NOT NULL,
	created_at timestamp with time zone DEFAULT now() NOT NULL,
	updated_by text NOT NULL,
	updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE public.entity_bindings OWNER TO "pg-user";

--------------------------------------------------------------------------------

CREATE INDEX entity_bindings_source_id_idx ON public.entity_bindings USING btree (source_id);

--------------------------------------------------------------------------------

CREATE INDEX entity_bindings_target_id_idx ON public.entity_bindings USING btree (target_id);

--------------------------------------------------------------------------------

CREATE INDEX entity_bindings_target_type_idx ON public.entity_bindings USING btree (target_type);

--------------------------------------------------------------------------------

ALTER TABLE public.entity_bindings
	ADD CONSTRAINT entity_bindings_pkey PRIMARY KEY (source_id, target_id);

--------------------------------------------------------------------------------

ALTER TABLE public.entity_bindings
	ADD CONSTRAINT entity_bindings_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.entries(entry_id) ON UPDATE CASCADE ON DELETE CASCADE;
