-- get next start nodes of the target edges.
CREATE OR REPLACE FUNCTION aadt.test_loop() RETURNS text AS $$
DECLARE row_cnt INT; 
        l_loop_cnt INT;
        
BEGIN   
-- find the next (and next next) edges connecting to the init target edges.

	l_loop_cnt := 0;
	row_cnt := 1;

		WITH two_ends AS --find the two ends of the known(red) edges
(
    SELECT edg_id,
        edg_nod_id_start,
        edg_nod_id_end
    FROM aadt.edges
        JOIN aadt.edge_values ON edges.edg_id = edge_values.egv_edg_id
),
red_nodes_start AS --find start node of the red known edge.
(
    SELECT edg_nod_id_start as red_nod_start_id,
        edg_id as red_nod_start_edg_id
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
)

        INSERT INTO aadt.edge_values_cal
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
    CASE
        WHEN aadt.init_nodes.evc_target_start = aadt.init_nodes.evc_edg_id_source_start THEN aadt.init_nodes.evc_edg_id_source_start
        WHEN aadt.init_nodes.evc_target_start = aadt.init_nodes.evc_edg_id_source_end THEN aadt.init_nodes.evc_edg_id_source_end
		WHEN aadt.init_nodes.evc_target_end = aadt.init_nodes.evc_edg_id_source_start THEN aadt.init_nodes.evc_edg_id_source_start
        WHEN aadt.init_nodes.evc_target_end = aadt.init_nodes.evc_edg_id_source_end THEN aadt.init_nodes.evc_edg_id_source_end
    END,
    CASE
        WHEN aadt.init_nodes.evc_target_start = aadt.init_nodes.evc_edg_id_source_start THEN aadt.init_nodes.evc_target_end
        WHEN aadt.init_nodes.evc_target_start = aadt.init_nodes.evc_edg_id_source_end THEN aadt.init_nodes.evc_target_end
		WHEN aadt.init_nodes.evc_target_end = aadt.init_nodes.evc_edg_id_source_start THEN aadt.init_nodes.evc_target_start
        WHEN aadt.init_nodes.evc_target_end = aadt.init_nodes.evc_edg_id_source_end THEN aadt.init_nodes.evc_target_start
    END,       
    edges.edg_egt_weight AS target_weight,
    edge_values.egv_aadt * edges.edg_egt_weight /(
        SUM(edges.edg_egt_weight) OVER (PARTITION BY init_nodes.evc_edg_id_source)
    ) AS target_aadt,
    init_nodes.evc_edg_id_source,
    init_nodes.evc_edg_id_source_start,
    init_nodes.evc_edg_id_source_end,
	edge_values.egv_aadt AS source_aadt


    
    FROM aadt.init_nodes
    JOIN aadt.edge_values ON init_nodes.evc_edg_id_source = edge_values.egv_edg_id
    JOIN aadt.edges on init_nodes.evc_edg_id_target = edges.edg_id
    WHERE aadt.edge_values.egv_id=1;



 

    
RETURN 
format ('%s rows affected', row_cnt);
END;
$$ LANGUAGE plpgsql;