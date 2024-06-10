CREATE OR REPLACE FUNCTION core.sf_create_embed(_public_key text, _entity_id bigint, _created_by text) RETURNS TABLE(decode_id bigint, encode_id text)
    LANGUAGE plpgsql ROWS 1
    AS $$
DECLARE
	_embedding_secret_id			bigint;
	_embed_id						bigint;
	_workbook_id					bigint;
BEGIN
	SELECT public.get_id() INTO _embedding_secret_id;
	SELECT public.get_id() INTO _embed_id;

	SELECT e.workbook_id INTO _workbook_id
	FROM public.entries AS e 
	WHERE e.entry_id = _entity_id;
	
	-- создаём embedding_secret
	INSERT INTO public.embedding_secrets(
	embedding_secret_id, title, workbook_id, public_key, created_by, created_at)
	VALUES (_embedding_secret_id, public.encode_id(_embedding_secret_id), _workbook_id, _public_key, _created_by, now());

	INSERT INTO public.embeds(
	embed_id, title, embedding_secret_id, entry_id, deps_ids, unsigned_params, created_by, created_at)
	VALUES (_embed_id, public.encode_id(_embed_id), _embedding_secret_id, _entity_id, '{}', '{}', _created_by, now());
	
	RETURN QUERY
		SELECT _embed_id, public.encode_id(_embed_id);
END
$$;

ALTER FUNCTION core.sf_create_embed(_public_key text, _entity_id bigint, _created_by text) OWNER TO us;

COMMENT ON FUNCTION core.sf_create_embed(_public_key text, _entity_id bigint, _created_by text) IS 'Создание ссылки для "Поделиться"';
