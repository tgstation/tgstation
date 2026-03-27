/// Proc to fetch all radios near an origin regardless of if they're in containers or not. Excludes origin obj/mob's contents.
/proc/get_radios_nearby(atom/origin, distance = 3, visible_only = FALSE)
	var/list/radios = list()
	var/obj/item/radio/radio = null
	var/atom/origin_turf = get_turf(origin) // so we can still see radio signals while in phased dummy
	var/list/movables
	if(visible_only)
		movables = view(distance, origin_turf)
	else
		movables = range(distance, origin_turf)
	for(var/atom/movable/movable in movables)
		if(movable == origin)
			continue
		if(istype(movable, /obj/item/radio))
			radio = movable
			radios += radio
		if(length(movable.contents))
			for(var/obj/content in movable.contents)
				if(istype(content, /obj/item/radio))
					radio = content
					radios += radio
	return radios

/// Get ALL listening radio items in a target.
/proc/get_all_listening_radios_in(atom/target)
	var/list/radios = list()
	var/obj/item/radio/radio = null
	for(var/atom/movable/content in target.contents)
		if(istype(content, /obj/item/radio))
			radio = content
			if(radio.is_on() && radio.get_listening())
				radios += radio
		else
			var/list/contained_radios = get_all_listening_radios_in(content)
			radios += contained_radios
	return radios
