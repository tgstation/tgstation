GLOBAL_LIST_INIT_TYPED(bb_gear, /datum/bb_gear, init_bb_gear())

/datum/bb_gear
	var/name
	var/desc
	var/spawn_path
	var/preview_path
	var/static/list/icon/cached_previews

/datum/bb_gear/proc/summon(mob/living/summoner, datum/team/brother_team/team)
	podspawn(list(
		"target" = get_turf(summoner),
		"style" = STYLE_SYNDICATE,
		"spawn" = spawn_path
	))

/datum/bb_gear/proc/preview()
	RETURN_TYPE(/icon)
	if(LAZYACCESS(cached_previews, type))
		return cached_previews[type]
	var/preview_source = preview_path || spawn_path
	if(ispath(preview_source))
		// using getFlatIcon here so we never have any problems with GAGS or overlay-reliant objects
		var/obj/thingymajig = new preview_source(null)
		. = getFlatIcon(thingymajig)
		qdel(thingymajig)
		LAZYSET(cached_previews, type, .)

/datum/bb_gear/proc/operator""()
	return "[name || type]"

/proc/init_bb_gear()
	. = list()
	for(var/datum/bb_gear/gear as anything in subtypesof(/datum/bb_gear))
		var/name = gear::name
		if(!istext(name))
			continue
		.[name] = new gear
