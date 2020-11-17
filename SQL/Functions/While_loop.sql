-- get init edges from one end of the red nodes
CREATE OR REPLACE FUNCTION get_init_nodes() RETURNS INT AS $$
DECLARE processed_nodes record;
BEGIN WITH two_ends AS --find the two ends of the known(red) edges
(
    SELECT edg_id,
        edg_nod_id_start,
        edg_nod_id_end
    FROM aadt.edges
        JOIN aadt.edge_values ON edges.edg_id = edge_values.egv_edg_id
),
red_nodes_start AS --find start node of the red known edge.
(
    SELECT edg_nod_id_start AS red_nod_start_id,
        edg_id AS red_nod_start_edg_id
    FROM two_ends
),
--find all edges that connect to the red known edges' start node.
target_start AS(
    SELECT edg_id AS edg_id_target,
        edg_egt_weight,
        edg_nod_id_start,
        edg_nod_id_end,
        red_nodes_start.red_nod_start_edg_id AS edg_id_source,
        red_nodes_start.red_nod_start_id AS source_start_id
    FROM aadt.edges
        JOIN red_nodes_start ON edg_id != red_nodes_start.red_nod_start_edg_id
        AND aadt.edges.edg_nod_id_start = red_nodes_start.red_nod_start_id
        OR aadt.edges.edg_nod_id_end = red_nodes_start.red_nod_start_id
    ORDER BY edg_id_source
),
init_target AS(
    SELECT edg_id_target,
        edges.edg_length AS target_length,
        target_start.edg_egt_weight AS target_weight,
        edg_id_source,
        edge_values.egv_aadt AS source_aadt,
        edge_values.egv_aadt * target_start.edg_egt_weight /(
            sum(target_start.edg_egt_weight) OVER (PARTITION BY edg_id_source)
        ) AS target_aadt,
        target_start.edg_nod_id_start AS target_start,
        target_start.edg_nod_id_end AS target_end,
        --query next_node column here
        CASE
            WHEN target_start.edg_nod_id_start = target_start.source_start_id THEN target_start.edg_nod_id_end
            WHEN target_start.edg_nod_id_end = target_start.source_start_id THEN target_start.edg_nod_id_start
        END AS next_node
    FROM target_start
        JOIN aadt.edge_values ON target_start.edg_id_source = edge_values.egv_edg_id
        JOIN aadt.edges on edg_id_target = edg_id
)
INSERT INTO aadt.edge_values_cal(
        evc_edg_id_target,
        evc_target_start,
        evc_target_end,
        evc_target_weight,
        evc_target_aadt,
        evc_edg_id_source,
        evc_edg_id_source_start,
        evc_edg_id_source_end,
        evc_source_aadt
    )
SELECT edg_id_target,
    target_start,
    target_end,
    target_weight,
    target_aadt,
    edg_id_source,
    edges.edg_nod_id_start,
    edges.edg_nod_id_end,
    source_aadt
FROM init_target
    JOIN aadt.edges ON edg_id_source = edges.edg_id;
RETURN processed_nodes;
END;
$$ LANGUAGE plpgsql;

SELECT get_init_nodes();

-- get next start nodes of the target edges.
CREATE OR REPLACE FUNCTION while_loop() RETURNS text AS $$
DECLARE row_cnt INT; 
        l_loop_cnt INT;
        f record;
BEGIN   
-- find the next (and next next) edges connecting to the init target edges.

l_loop_cnt := 0;

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
    edges.edg_nod_id_end AS source_end,
    
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
    edges.edg_nod_id_end AS source_end,
    
    FROM aadt.edge_values_cal
    JOIN aadt.edge_values ON target_start.edg_id_source = edge_values.egv_edg_id
    JOIN aadt.edges on edg_id_target = edg_id

    WHERE evc_target_start = evc_edg_id_source_start
            OR evc_target_start = evc_edg_id_source_end
            AND evc_flag IS null

    evc_edg_id_source_start := evc_target_start;
    evc_edg_id_source_end := evc_target_end;
    evc_edg_id_source := evc_edg_id_target;
    edge_values.egv_aadt := target_aadt;
    edges.edg_egt_weight := target_weight;

        GET DIAGNOSTICS row_cnt = ROW_COUNT;
        UPDATE edge_values_calc 
        SET evc_flag = true where inserted

        l_loop_cnt := l_loop_cnt + 1;

    END LOOP;
RETURN 
format ('%s rows affected', row_count);
END;
$$ LANGUAGE plpgsql;