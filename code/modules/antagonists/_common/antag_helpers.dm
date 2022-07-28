//Returns MINDS of the assigned antags of given type/subtypes
/proc/get_antag_minds(antag_type,specific = FALSE)
	RETURN_TYPE(/list/datum/mind)
	. = list()
	for(var/datum/antagonist/A in GLOB.antagonists)
		if(!A.owner)
			continue
		if(!antag_type || !specific && istype(A,antag_type) || specific && A.type == antag_type)
			. += A.owner

/proc/sort_by_most_played(list/minds_to_sort)
	var/list/sorted_players = list()
	var/list/clients_to_sort = list()
	var/list/minds_without_clients = list()
	for(var/datum/mind/mind as anything in minds_to_sort)
		if(!mind.current.client)
			minds_without_clients += mind
			continue
		clients_to_sort += mind.current.client
	clients_to_sort = sort_list(clients_to_sort, /proc/cmp_playtime_dsc)
	for(var/client/client as anything in clients_to_sort)
		sorted_players += client.mob.mind
	sorted_players += minds_without_clients
