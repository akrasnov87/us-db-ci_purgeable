START TRANSACTION;

CREATE OR REPLACE FUNCTION core.sf_create_embed(
	_public_key text,
	_entity_id bigint,
	_created_by text,
	_reject text)
    RETURNS TABLE(decode_id bigint, encode_id text, existsing boolean) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1

AS $BODY$
DECLARE
	_embedding_secret_id			bigint;
	_embed_id						bigint;
	_workbook_id					bigint;
	_existsing						boolean = false;
BEGIN
	SELECT public.get_id() INTO _embedding_secret_id;
	SELECT public.get_id() INTO _embed_id;

	SELECT e.workbook_id INTO _workbook_id
	FROM public.entries AS e 
	WHERE e.entry_id = _entity_id;

	IF lower(_reject) = 'true' THEN
		-- удаляем старую ссылку
		DELETE FROM public.embeds AS e 
		WHERE e.entry_id = _entity_id AND e.created_by = _created_by;
	END IF;

	IF (SELECT COUNT(*) FROM public.embeds AS e WHERE e.entry_id = _entity_id AND e.created_by = _created_by) = 0 THEN
		-- создаём embedding_secret
		INSERT INTO public.embedding_secrets(
		embedding_secret_id, title, workbook_id, public_key, created_by, created_at)
		VALUES (_embedding_secret_id, public.encode_id(_embedding_secret_id), _workbook_id, _public_key, _created_by, now());
	
		INSERT INTO public.embeds(
		embed_id, title, embedding_secret_id, entry_id, deps_ids, unsigned_params, created_by, created_at, updated_by)
		VALUES (_embed_id, public.encode_id(_embed_id), _embedding_secret_id, _entity_id, '{}', '{}', _created_by, now(), _created_by);
	ELSE
		SELECT true INTO _existsing;

		-- достаём ранее созданный
		SELECT e.embed_id INTO _embed_id
		FROM public.embeds AS e
		WHERE e.entry_id = _entity_id AND e.created_by = _created_by;
	END IF;

	RETURN QUERY
		SELECT _embed_id, public.encode_id(_embed_id), _existsing;
END
$BODY$;

ALTER FUNCTION core.sf_create_embed(text, bigint, text, text)
    OWNER TO us;

COMMENT ON FUNCTION core.sf_create_embed(text, bigint, text, text)
    IS 'Создание ссылки для "Поделиться"';

-- добавление безопасности   
INSERT INTO core.pd_accesses(f_role, c_name, c_function, b_deletable, b_creatable, b_editable, b_full_control)
VALUES
(2, 'structure-items',NULL,	false,	false,	false,	false),
(3, 'structure-items',NULL,	false,	false,	false,	false);

COMMIT TRANSACTION;