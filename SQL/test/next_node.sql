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
        red_nodes_start.red_nod_start_edg_id AS edg_id_source,
        red_nodes_start.red_nod_start_id AS source_start_id
    FROM edges
        JOIN red_nodes_start ON edg_id != red_nodes_start.red_nod_start_edg_id
        AND edges.edg_nod_id_start = red_nodes_start.red_nod_start_id
        OR edges.edg_nod_id_end = red_nodes_start.red_nod_start_id
    ORDER BY edg_id_source
)
SELECT edg_id_target,
    edges.edg_length AS target_length,
    target_start.edg_egt_weight,
    edg_id_source,
    edge_values.egv_aadt AS source_aadt,
    edge_values.egv_aadt * target_start.edg_egt_weight /(
        sum(target_start.edg_egt_weight) over (partition by edg_id_source)
    ) AS target_aadt,
    target_start.edg_nod_id_start,
    target_start.edg_nod_id_end,
    --query next_node column here
    case
        when target_start.edg_nod_id_start = target_start.source_start_id then target_start.edg_nod_id_end
        when target_start.edg_nod_id_end = target_start.source_start_id then target_start.edg_nod_id_start
    end AS next_node
FROM target_start
    JOIN edge_values ON target_start.edg_id_source = edge_values.egv_edg_id
    JOIN edges on edg_id_target = edg_id