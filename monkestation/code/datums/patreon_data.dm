/client
	var/datum/patreon_data/patreon

/datum/patreon_data
	///the client that owns this data
	var/client/owner
	///the stored patreon client key for the information
	var/client_key
	///the stored patreon rank collected from the server
	var/owned_rank = NO_RANK
	///access rank in numbers
	var/access_rank = 0


/datum/patreon_data/New(client/created_client)
	. = ..()
	if(!created_client)
		return

	if(!SSdbcore.IsConnected())
		owned_rank = NUKIE_RANK ///this is a testing variable
		return

	owner = created_client

	fetch_key(owner.ckey)
	fetch_rank(owner.ckey)

	assign_access_rank()


/datum/patreon_data/proc/fetch_key(ckey)
	var/datum/db_query/query_get_key = SSdbcore.NewQuery("SELECT patreon_key FROM [format_table_name("player")] WHERE ckey = '[ckey]'")
	if(query_get_key.warn_execute())
		if(query_get_key.NextRow())
			client_key = query_get_key.item[1]
	qdel(query_get_key)

/datum/patreon_data/proc/fetch_rank(ckey)
	var/datum/db_query/query_get_rank = SSdbcore.NewQuery("SELECT patreon_rank FROM [format_table_name("player")] WHERE ckey = '[ckey]'")
	if(query_get_rank.warn_execute())
		if(query_get_rank.NextRow())
			if(query_get_rank.item[1])
				owned_rank = query_get_rank.item[1]
				if(owned_rank == "UNSUBBED2")
					owned_rank = NO_RANK
			else
				owned_rank = NO_RANK
	qdel(query_get_rank)


/datum/patreon_data/proc/assign_access_rank()
	switch(owned_rank)
		if(THANKS_RANK)
			access_rank =  ACCESS_THANKS_RANK
		if(ASSISTANT_RANK)
			access_rank =  ACCESS_ASSISTANT_RANK
		if(COMMAND_RANK)
			access_rank =  ACCESS_COMMAND_RANK
		if(TRAITOR_RANK)
			access_rank =  ACCESS_TRAITOR_RANK
		if(NUKIE_RANK, OLD_NUKIE_RANK)
			access_rank =  ACCESS_NUKIE_RANK

/datum/patreon_data/proc/has_access(rank)
	if(!access_rank)
		assign_access_rank()
	if(rank <= access_rank)
		return TRUE
	return FALSE

/datum/patreon_data/proc/is_donator()
	if((owned_rank != NO_RANK) && (owned_rank != UNSUBBED))
		return TRUE
	return FALSE
