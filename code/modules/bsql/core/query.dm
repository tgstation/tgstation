/datum/BSQL_Operation/Query
	var/last_result_json
	var/list/last_result

BSQL_PROTECT_DATUM(/datum/BSQL_Operation/Query)

/datum/BSQL_Operation/Query/CurrentRow()
	return last_result

/datum/BSQL_Operation/Query/IsComplete()
	//whole different ballgame here
	if(BSQL_IS_DELETED(connection))
		return TRUE
	var/result = world._BSQL_Internal_Call("ReadyRow", connection.id, id)
	switch(result)
		if("DONE")
			//load the data
			last_result_json = world._BSQL_Internal_Call("GetRow", connection.id, id)
			if(last_result_json)
				last_result = json_decode(last_result_json)
			else
				last_result = null
			return TRUE
		if("NOTDONE")
			return FALSE
		else
			BSQL_ERROR(result)
