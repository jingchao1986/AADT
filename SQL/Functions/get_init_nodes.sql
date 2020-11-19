/*****************************************************************************
 NAME:        get_init_nodes
 DESCRIPTION: 	get init nodes and edges from one end of the source edge
				
 TEST PROC:		
 CREATED BY:		Jingchao Zhou
 CREATED AT:		11/19/2020
 HISTORY:			
	11/19/2020:	jz Initial code
	
 NOTES:
******************************************************************************/

CREATE OR REPLACE FUNCTION aadt.get_init_nodes() RETURNS INT AS $$
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
),
init_target AS(
    SELECT edg_id_target,
        edges.edg_length AS target_length,
        target_start.edg_egt_weight AS target_weight,
        edg_id_source,
        edge_values.egv_aadt AS source_aadt,
        edge_values.egv_aadt * target_start.edg_egt_weight /(
            sum(target_start.edg_egt_weight) over (partition by edg_id_source)
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
        JOIN aadt.edges ON edg_id_target = edg_id
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

