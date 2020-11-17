-- get next start nodes of the target edges.
CREATE OR REPLACE FUNCTION get_next_nodes() RETURNS text AS $$
DECLARE f record; n int;

BEGIN 
    FOR f IN
        SELECT *
        FROM edge_values_cal
        WHERE evc_target_start = evc_edg_id_source_start
            or evc_target_start = evc_edg_id_source_end
            AND evc_flag IS null 

            LOOP
            INSERT INTO edge_values_cal(evc_target_start)
            SELECT f.evc_target_end;
            UPDATE edge_values_cal
            set evc_flag = 'true';
        END LOOP;

    FOR f IN
    SELECT *
    FROM edge_values_cal
    WHERE evc_target_end = evc_edg_id_source_start
        or evc_target_end = evc_edg_id_source_end
        AND edge_values_cal.evc_flag IS null 
        
        LOOP
        INSERT INTO edge_values_cal(evc_target_start)
        SELECT f.evc_target_start;
        UPDATE edge_values_cal
        SET evc_flag = 'true';
    END LOOP;

    GET DIAGNOSTIC n = row_count;
    RETURN format ('%s rows affected', n);
END;
$$ LANGUAGE plpgsql;