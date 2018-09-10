GLOBAL_DATUM_INIT(text_filter_datum, /datum/text_filter, new)

/datum/text_filter
	//used for some text operations that need to hold a bunch of regexes or whatever in memory
	//probably not the best way to do it, but globals are bad
	var/static/regex/reeegex = new(@"\b[Rr]+[Ee]{2,}\b")
	var/static/regex/yeetgex = new(@"\b[Yy]+[Ee]{2,}[Tt]+([Ee][Dd])?([Ii][Nn][Gg])?\b")

/datum/text_filter/proc/ree_check(message)
	if(reeegex.Find(message))
		return TRUE
	return FALSE

return FALSE
 /datum/text_filter/proc/yeet_check(message)
	if(yeetgex.Find(message))
		return TRUE