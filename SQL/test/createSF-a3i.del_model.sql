/*****************************************************************************
 NAME:        a3i.del_model
 DESCRIPTION: 	delete a model 
				
 TEST PROC:		
 CREATED BY:		bg
 CREATED AT:		8/1/2017
 HISTORY:			
	8/1/2017:	bg Initial code
	11/25/2017:	bg change to use json rather than jsonb
	7/5/2018:	bg change to use internal session management, change parameters.
					add p_usb_id, removed p_urs_id and session_id
					rename from delete_model
	7/6/2018:	bg add session id to the payload
	7/6/2018:	bg reverse to use p_usr_id instead of p_usb_id
	01/22/2019:	bg change from project based to customer based design
	
 NOTES:
******************************************************************************/
DROP FUNCTION IF EXISTS a3i.del_model(integer, integer);

CREATE OR REPLACE FUNCTION a3i.del_model(
	p_mdl_id integer,
	p_usr_id integer)
  RETURNS json
  LANGUAGE 'plpgsql' SECURITY DEFINER
AS $function$
DECLARE
	l_msg TEXT = NULL;
	l_rowcount INTEGER = -1;
	l_json JSON = NULL;
    l_session_id TEXT;
   
BEGIN
	-- ensure model name exist
	IF EXISTS (SELECT 1 FROM a3i.models 
									WHERE  mdl_id = p_mdl_id 
									AND mdl_tranx_delete IS NULL) THEN  
		
		l_session_id = lba._manage_session(	p_action_cd  :='START',
											p_mod_cd  := 'A3I',
											p_usr_id := p_usr_id,
											p_session_type := 'SYSTEM',
											p_session_desc := 'Delete a model',
											p_session_id := NULL);


		-- update the project with prj_tranx_delete
		WITH A AS (
		UPDATE a3i.models
			SET mdl_tranx_delete = l_session_id
			WHERE mdl_id = p_mdl_id AND mdl_tranx_delete IS NULL
					RETURNING mdl_id, mdl_cus_id)
		SELECT INTO l_rowcount, l_json 
			COUNT(1), json_agg(json_build_object ('session_id', l_session_id, 'cus_id', mdl_cus_id,'mdl_id', mdl_id))
			FROM A;

	ELSE
	
		l_msg = 'Model not found.';
	
	END IF;
	
	
	IF l_msg IS NULL THEN
	
		l_json = lba._get_std_payload (p_count := l_rowcount, p_result := l_json);

	ELSE
	
		l_json = lba._get_std_payload (p_count := l_rowcount, 
										p_result := l_json, 
										p_error := json_build_object('message',l_msg));
	
	END IF;
	
	RETURN l_json;
		
END; 
$function$;

