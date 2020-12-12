/datum/cultural_info/location
	var/distance
	var/ruling_body
	var/capital

/datum/cultural_info/location/get_extra_desc(more = FALSE)
	. = ..()
	if(!more)
		return
	. += "<BR>Distance: [distance ? "[distance]" : "Unknown"]"
	. += "<BR>Ruler: [ruling_body ? "[ruling_body]" : "Various"]"
	. += "<BR>Capital: [capital ? "[capital]" : "Unknown"]"
