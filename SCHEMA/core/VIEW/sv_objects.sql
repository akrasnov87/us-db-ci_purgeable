CREATE VIEW core.sv_objects AS
	SELECT table1.table_name,
    table1.table_type,
    table1.table_title,
    table1.primary_key,
    table1.table_comment,
    table1.table_schema
   FROM ( SELECT (t.table_name)::character varying AS table_name,
            (t.table_type)::character varying AS table_type,
            (pgd.description)::character varying AS table_title,
            (cc.column_name)::character varying AS primary_key,
            ''::character varying AS table_comment,
            t.table_schema
           FROM ((((information_schema.tables t
             LEFT JOIN pg_statio_all_tables st ON ((st.relname = (t.table_name)::name)))
             LEFT JOIN pg_description pgd ON (((pgd.objoid = st.relid) AND (pgd.objsubid = 0))))
             LEFT JOIN information_schema.table_constraints tc ON ((((t.table_name)::text = (tc.table_name)::text) AND ((t.table_catalog)::text = (tc.table_catalog)::text))))
             LEFT JOIN information_schema.constraint_column_usage cc ON (((tc.constraint_name)::text = (cc.constraint_name)::text)))
          WHERE (((t.table_catalog)::text = (current_database())::text) AND ((tc.constraint_type)::text = 'PRIMARY KEY'::text))
        UNION
         SELECT (t.table_name)::character varying AS table_name,
            (t.table_type)::character varying AS table_type,
            (pgd.description)::character varying AS table_title,
            ''::character varying AS primary_key,
            ''::character varying AS table_comment,
            t.table_schema
           FROM ((information_schema.tables t
             LEFT JOIN pg_class pgc ON ((pgc.relname = (t.table_name)::name)))
             LEFT JOIN pg_description pgd ON ((pgd.objoid = pgc.oid)))
          WHERE (((t.table_type)::text = 'VIEW'::text) AND ((t.table_catalog)::text = (current_database())::text))
        UNION
         SELECT (r.routine_name)::character varying AS table_name,
            (r.routine_type)::character varying AS table_type,
            (pgd.description)::character varying AS table_title,
            ''::character varying AS primary_key,
            ''::character varying AS table_comment,
            r.routine_schema AS table_schema
           FROM ((information_schema.routines r
             LEFT JOIN pg_proc pgp ON ((pgp.proname = (r.routine_name)::name)))
             LEFT JOIN pg_description pgd ON ((pgd.objoid = pgp.oid)))
          WHERE ((r.routine_catalog)::text = (current_database())::text)) table1
  WHERE (((table1.table_schema)::text <> 'pg_catalog'::text) AND ((table1.table_schema)::text <> 'information_schema'::text) AND ((table1.table_schema)::text <> 'public'::text));

ALTER VIEW core.sv_objects OWNER TO us;
