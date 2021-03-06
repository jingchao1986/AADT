WITH two_ends AS --find the two ends of the known(red) edges
(
    SELECT edg_id,
        edg_nod_id_start,
        edg_nod_id_end
    FROM edges
        JOIN edge_values ON edges.edg_id = edge_values.egv_edg_id
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
        red_nodes_start.red_nod_start_edg_id AS edg_id_source
    FROM edges
        JOIN red_nodes_start ON edg_id != red_nodes_start.red_nod_start_edg_id
        AND edges.edg_nod_id_start = red_nodes_start.red_nod_start_id
        OR edges.edg_nod_id_end = red_nodes_start.red_nod_start_id
    ORDER BY red_nod_start_edg_id
)
SELECT edg_id_target,
    edg_egt_weight,
    edg_id_source,
    edge_values.egv_aadt
FROM target_start
    JOIN edge_values ON target_start.edg_id_source = edge_values.egv_edg_id