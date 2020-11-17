select edges.edg_id, egv_aadt/3, egv_edg_id from edge_values
left join edges

where edges.edg_nod_id_start = 2 or edges.edg_no_id_end =10 or edges.edg_nod_id_start = 10
or edges.edg_no_id_end =2;
