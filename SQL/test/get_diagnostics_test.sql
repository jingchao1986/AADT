DO $$ 
DECLARE n INT; n_total INT;
BEGIN
	PERFORM * FROM edges;
	GET DIAGNOSTICS n = row_count;
	n_total := n;

	INSERT INTO edge_values_cal (evc_id) VALUES(992);
	GET DIAGNOSTICS n = row_count;
	n_total := n_total + n;
	
   RAISE NOTICE '%', n_total;
END$$;