
-- get next start nodes of the target edges.
CREATE OR REPLACE FUNCTION while_loop() RETURNS text AS $$
DECLARE row_cnt INT; 
        l_loop_cnt INT;
        evc_edg_id_source_start record;
		evc_edg_id_source_end record;
		evc_edg_id_source record;
		edge_values_egv_aadt record;
		edges_edg_egt_weight record;
		
BEGIN   
-- find the next (and next next) edges connecting to the init target edges.

	l_loop_cnt := 0;
	evc_edg_id_source_start := aadt.evc_edg_id_source_start;
	evc_edg_id_source_end := aadt.evc_edg_id_source_end;
	evc_edg_id_source := aadt.evc_edg_id_source;
	edge_values_egv_aadt := aadt.edge_values.egv_aadt;
	edges_edg_egt_weight := aadt.edges.edg_egt_weight;


    GET DIAGNOSTICS row_cnt = ROW_COUNT;

    WHILE rowcount > 0 AND l_loop_cnt < 50

    LOOP
        -- INSERT INTO edge_values_cal
        --     (evc_edg_id_target,
        --     evc_target_start,
        --     evc_target_end,
        --     evc_target_weight,
        --     evc_target_aadt,
        --     evc_edg_id_source,
        --     evc_edg_id_source_start,
        --     evc_edg_id_source_end,
        --     evc_source_aadt)
        -- SELECT evc_target_start
        -- FROM edge_values_cal
        -- WHERE evc_target_start = evc_edg_id_source_start
        --     or evc_target_start = evc_edg_id_source_end
        --     AND evc_flag IS null

        -- UNION ALL
        -- SELECT evc_target_end
        -- FROM edge_values_cal
        -- WHERE evc_target_end = evc_edg_id_source_start
        --     or evc_target_end = evc_edg_id_source_end
        --     AND evc_flag IS null;

        INSERT INTO edge_values_cal
            (evc_edg_id_target,
            evc_target_start,
            evc_target_end,
            evc_target_weight,
            evc_target_aadt,
            evc_edg_id_source,
            evc_edg_id_source_start,
            evc_edg_id_source_end,
            evc_source_aadt)
                
    SELECT 
    aadt.edges.edg_id, 
    evc_target_start,
    CASE
        WHEN evc_target_start = evc_edg_id_source_start THEN evc_edg_id_source_end
        WHEN evc_target_start = evc_edg_id_source_end THEN evc_edg_id_source_start
    END,       
    edges.edg_egt_weight AS target_weight,
    edge_values.egv_aadt * edges.edg_egt_weight /(
        SUM(edges.edg_egt_weight) OVER (PARTITION BY evc_edg_id_source)
    ) AS target_aadt,
    evc_edg_id_source,
    edge_values.egv_aadt AS source_aadt,
    edges.edg_nod_id_start AS source_start,
    edges.edg_nod_id_end AS source_end
    
    FROM aadt.edge_values_cal
    JOIN aadt.edge_values ON target_start.edg_id_source = edge_values.egv_edg_id
    JOIN aadt.edges on edg_id_target = edg_id

    WHERE evc_target_start = evc_edg_id_source_start
            OR evc_target_start = evc_edg_id_source_end
            AND evc_flag IS null

    UNION ALL
    SELECT 
    edges.edg_id, 
    evc_target_end,
    CASE
        WHEN evc_target_end = evc_edg_id_source_start THEN evc_edg_id_source_end
        WHEN evc_target_end = evc_edg_id_source_end THEN evc_edg_id_source_start
    END,       
    edges.edg_egt_weight AS target_weight,
    edge_values.egv_aadt * edges.edg_egt_weight /(
        SUM(edges.edg_egt_weight) OVER (PARTITION BY evc_edg_id_source)
    ) AS target_aadt,
    evc_edg_id_source,
    edge_values.egv_aadt AS source_aadt,
    edges.edg_nod_id_start AS source_start,
    edges.edg_nod_id_end AS source_end
    
    FROM aadt.edge_values_cal
    JOIN aadt.edge_values ON target_start.edg_id_source = edge_values.egv_edg_id
    JOIN aadt.edges on edg_id_target = edg_id

    WHERE evc_target_start = evc_edg_id_source_start
            OR evc_target_start = evc_edg_id_source_end
            AND evc_flag IS null;

	
    evc_edg_id_source_start := evc_target_start;
    evc_edg_id_source_end := evc_target_end;
    evc_edg_id_source := evc_edg_id_target;
    edge_values_egv_aadt := target_aadt;
    edges_edg_egt_weight := target_weight;

        GET DIAGNOSTICS row_cnt = ROW_COUNT;
        UPDATE edge_values_calc 
        SET evc_flag = true where inserted;

        l_loop_cnt := l_loop_cnt + 1;

    END LOOP;
RETURN 
format ('%s rows affected', row_count);
END;
$$ LANGUAGE plpgsql;