GLOBAL_LIST_INIT(blessed_ckeys, list(
	"taocat" = list(3, 25),
)) //this is a lmao moment should be a json but its being left here because lol it goes ckey = list(multiplier, base)

///adjusts antag rep by {VALUE} keeping the value above 0
/datum/preferences/proc/adjust_antag_rep(value, multiplier = TRUE)
	if(multiplier)
		value *= return_rep_multiplier()
	log_antag_rep("[parent]'s antag rep was adjusted by [value]")
	antag_rep += value
	if(antag_rep < 1)
		log_antag_rep("[parent]'s antag rep was adjusted below 1 resetting to 1")
		antag_rep = 1
	save_preferences()

/datum/preferences/proc/reset_antag_rep()
	var/default = return_default_antag_rep()
	log_antag_rep("[parent]'s antag rep was reset to default ([default])")
	antag_rep = default
	save_preferences()

/datum/preferences/proc/return_default_antag_rep()
	if(!parent)
		return 10
	if(!(parent.ckey in GLOB.blessed_ckeys))
		return 10
	return GLOB.blessed_ckeys[parent.ckey][2]

/datum/preferences/proc/return_rep_multiplier()
	if(!parent)
		return 1
	if(!(parent.ckey in GLOB.blessed_ckeys))
		return 1
	return GLOB.blessed_ckeys[parent.ckey][1]


///give it a list of clients and the value aswell if it should be affected by multipliers and let er rip
/proc/mass_adjust_antag_rep(list/clients, value, mulitplier = TRUE)
	for(var/client/listed_client as anything in clients)
		if(!listed_client.prefs || !IS_CLIENT_OR_MOCK(listed_client))
			continue
		listed_client.prefs.adjust_antag_rep(value, mulitplier)

/proc/return_antag_rep_weight(list/candidates)
	var/list/returning_list = list()
	for(var/anything in candidates)
		var/client/client_source
		if(ismob(anything))
			var/mob/mob = anything
			client_source = mob.client
		if(IS_CLIENT_OR_MOCK(anything))
			client_source = anything
		if(!client_source)
			continue

		returning_list += client_source
		var/return_value = 10
		if(client_source.prefs?.antag_rep)
			return_value = client_source.prefs.antag_rep
		returning_list[client_source] = return_value

	return returning_list
