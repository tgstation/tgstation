/datum/map_template/shelter
	var/shelter_id
	var/description
	var/blacklisted_turfs
	var/whitelisted_turfs
	var/banned_areas
	var/banned_objects

/datum/map_template/shelter/New()
	. = ..()
	blacklisted_turfs = typecacheof(/turf/closed)
	whitelisted_turfs = list()
	banned_areas = typecacheof(/area/shuttle)
	banned_objects = list()

/datum/map_template/shelter/proc/check_deploy(turf/deploy_location)
	var/affected = get_affected_turfs(deploy_location, centered=TRUE)
	for(var/turf/T in affected)
		var/area/A = get_area(T)
		if(is_type_in_typecache(A, banned_areas))
			return SHELTER_DEPLOY_BAD_AREA

		var/banned = is_type_in_typecache(T, blacklisted_turfs)
		var/permitted = is_type_in_typecache(T, whitelisted_turfs)
		if(banned && !permitted)
			return SHELTER_DEPLOY_BAD_TURFS

		for(var/obj/O in T)
			if((O.density && O.anchored) || is_type_in_typecache(O, banned_objects))
				return SHELTER_DEPLOY_ANCHORED_OBJECTS
	return SHELTER_DEPLOY_ALLOWED

/datum/map_template/shelter/alpha
	name = "Shelter Alpha"
	shelter_id = "shelter_alpha"
	description = "A cosy self-contained pressurized shelter, with \
		built-in navigation, entertainment, medical facilities and a \
		sleeping area! Order now, and we'll throw in a TINY FAN, \
		absolutely free!"
	mappath = "_maps/templates/shelter_1.dmm"

/datum/map_template/shelter/alpha/New()
	. = ..()
	whitelisted_turfs = typecacheof(/turf/closed/mineral)
	banned_objects = typecacheof(/obj/structure/stone_tile)

/datum/map_template/shelter/beta
	name = "Shelter Beta"
	shelter_id = "shelter_beta"
	description = "An extremly luxurious shelter, containing all \
		the amenities of home, including carpeted floors, hot and cold \
		running water, a gourmet three course meal, cooking facilities, \
		and a deluxe companion to keep you from getting lonely during \
		an ash storm."
	mappath = "_maps/templates/shelter_2.dmm"

/datum/map_template/shelter/beta/New()
	. = ..()
	whitelisted_turfs = typecacheof(/turf/closed/mineral)
	banned_objects = typecacheof(/obj/structure/stone_tile)
