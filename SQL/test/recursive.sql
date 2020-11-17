-- get next start nodes of the target edges.
CREATE OR REPLACE FUNCTION get_next_nodes() RETURNS text AS $$
DECLARE f record; n int;
BEGIN FOR f IN
SELECT *
FROM edge_values_cal
WHERE evc_target_start = evc_edg_id_source_start
    or evc_target_start = evc_edg_id_source_end
    AND evc_flag IS null LOOP
INSERT INTO edge_values_cal(evc_target_start)
SELECT f.evc_target_end;
UPDATE edge_values_cal
set evc_flag = 'true';
END LOOP;
RETURNING f.evc_target_end INTO next_nodes;

FOR f IN
SELECT *
FROM edge_values_cal
WHERE evc_target_end = evc_edg_id_source_start
    or evc_target_end = evc_edg_id_source_end
    AND edge_values_cal.evc_flag IS null LOOP
INSERT INTO edge_values_cal(evc_target_start)
SELECT f.evc_target_start;
UPDATE edge_values_cal
SET evc_flag = 'true';
END LOOP;
RETURNING f.evc_target_start INTO next_nodes;


WITH find_paths AS(

Select t1.evc_target_start, 0 as Depth
From edge_values_cal t1
Where t1.evc_target_start = next_nodes
Union All 
Select t2.evc_target_start, Depth + 1
From edges t2
    Join edges 
        On edges.edg_nod_id_start = t1.evc_target_start
		or edges.edg_nod_id_end = t1.evc_target_start
) 
INSERT INTO edges_values_cal
Select *
From find_path;

get diagnostics n = row_count;
return 
    format ('%s rows affected', n);
END;
$$ LANGUAGE plpgsql;