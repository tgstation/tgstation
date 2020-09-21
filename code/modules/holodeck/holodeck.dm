
/datum/map_template/holodeck
	var/template_id
	var/description
	var/blacklisted_turfs
	var/whitelisted_turfs
	var/banned_areas
	var/banned_objects
	var/restricted = FALSE
	var/list/spawned_atoms
	var/datum/parsed_map/lastparsed

	/*
	var/name = "Default Template Name"
	var/width = 0
	var/height = 0
	var/mappath = null
	var/loaded = 0 // Times loaded this round
	var/datum/parsed_map/cached_map
	var/keep_cached_map = FALSE
	*/
	var/obj/machinery/computer/holodeck/linked
	 // if true, program goes on emag list

/datum/map_template/holodeck/New()
	. = ..()
	/*blacklisted_turfs = typecacheof(/turf/closed)
	whitelisted_turfs = list()
	banned_areas = typecacheof(/area/shuttle)
	banned_objects = list()*/

/*
/datum/map_template/holodeck/proc/check_deploy(turf/deploy_location)
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
	*/


/datum/map_template/holodeck/lounge//the l in lounge starts after space 29
	name = "Holodeck - Lounge"
	template_id = "holodeck_lounge"
	description = "benis"
	mappath = "_maps/templates/holodeck_lounge.dmm"

/datum/map_template/holodeck/offline
	name = "Holodeck - Offline"
	template_id = "holodeck_offline"
	description = "benis"
	mappath = "_maps/templates/holodeck_offline.dmm"

/datum/map_template/holodeck/anime_school
	name = "Holodeck - Anime School"
	template_id = "holodeck_animeschool"
	description = "benis"
	mappath = "_maps/templates/holodeck_animeschool.dmm"

/datum/map_template/holodeck/basketball
	name = "Holodeck - Basketball Court"
	template_id = "holodeck_basketball"
	description = "benis"
	mappath = "_maps/templates/holodeck_basketball.dmm"

/datum/map_template/holodeck/beach
	name = "Holodeck - Beach"
	template_id = "holodeck_beach"
	description = "benis"
	mappath = "_maps/templates/holodeck_beach.dmm"

/datum/map_template/holodeck/chapelcourt
	name = "Holodeck - Chapel Courtroom"
	template_id = "holodeck_chapelcourt"
	description = "benis"
	mappath = "_maps/templates/holodeck_chapelcourt.dmm"

/datum/map_template/holodeck/dodgeball
	name = "Holodeck - Dodgeball Court"
	template_id = "holodeck_dodgeball"
	description = "benis"
	mappath = "_maps/templates/holodeck_dodgeball.dmm"

/datum/map_template/holodeck/emptycourt
	name = "Holodeck - Empty Court"
	template_id = "holodeck_emptycourt"
	description = "benis"
	mappath = "_maps/templates/holodeck_emptycourt.dmm"

/datum/map_template/holodeck/firingrange
	name = "Holodeck - Firing Range"
	template_id = "holodeck_firingrange"
	description = "benis"
	mappath = "_maps/templates/holodeck_firingrange.dmm"

/datum/map_template/holodeck/petpark
	name = "Holodeck - Pet Park"
	template_id = "holodeck_petpark"
	description = "benis"
	mappath = "_maps/templates/holodeck_petpark.dmm"

/datum/map_template/holodeck/photobooth
	name = "Holodeck - Photobooth"
	template_id = "holodeck_photobooth"
	description = "benis"
	mappath = "_maps/templates/holodeck_photobooth.dmm"

/datum/map_template/holodeck/skatepark
	name = "Holodeck - Skatepark"
	template_id = "holodeck_skatepark"
	description = "benis"
	mappath = "_maps/templates/holodeck_skatepark.dmm"

/datum/map_template/holodeck/spacecheckers
	name = "Holodeck - Space Checkers"
	template_id = "holodeck_spacecheckers"
	description = "benis"
	mappath = "_maps/templates/holodeck_spacecheckers.dmm"

/datum/map_template/holodeck/spacechess
	name = "Holodeck - Space Chess"
	template_id = "holodeck_spacechess"
	description = "benis"
	mappath = "_maps/templates/holodeck_spacechess.dmm"

/datum/map_template/holodeck/thunderdome
	name = "Holodeck - Thunderdome Arena"
	template_id = "holodeck_thunderdome"
	description = "benis"
	mappath = "_maps/templates/holodeck_thunderdome.dmm"

/datum/map_template/holodeck/winterwonderland
	name = "Holodeck - Winter Wonderland"
	template_id = "holodeck_winterwonderland"
	description = "benis"
	mappath = "_maps/templates/holodeck_winterwonderland.dmm"

/datum/map_template/holodeck/thunderdome1218
	name = "Holodeck - 1218 AD"
	template_id = "holodeck_thunderdome1218"
	description = "benis"
	mappath = "_maps/templates/holodeck_thunderdome1218.dmm"
	restricted = TRUE

/datum/map_template/holodeck/wildlifesim
	name = "Holodeck - Wildlife Simulation"
	template_id = "holodeck_wildlifesim"
	description = "benis"
	mappath = "_maps/templates/holodeck_wildlifesim.dmm"
	restricted = TRUE

/datum/map_template/holodeck/refuelingstation
	name = "Holodeck - Refueling Station"
	template_id = "holodeck_refuelingstation"
	description = "benis"
	mappath = "_maps/templates/holodeck_refuelingstation.dmm"
	restricted = TRUE

/datum/map_template/holodeck/holdoutbunker
	name = "Holodeck - Holdout Bunker"
	template_id = "holodeck_holdoutbunker"
	description = "benis"
	mappath = "_maps/templates/holodeck_holdoutbunker.dmm"
	restricted = TRUE

/datum/map_template/holodeck/medicalsim
	name = "Holodeck - Emergency Medical"
	template_id = "holodeck_medicalsim"
	description = "benis"
	mappath = "_maps/templates/holodeck_medicalsim.dmm"
	restricted = TRUE

/datum/map_template/holodeck/burntest
	name = "Holodeck - Atmospheric Burn Test"
	template_id = "holodeck_burntest"
	description = "benis"
	mappath = "_maps/templates/holodeck_burntest.dmm"
	restricted = TRUE

/datum/map_template/holodeck/anthophillia
	name = "Holodeck - Anthophillia"
	template_id = "holodeck_anthophillia"
	description = "benis"
	mappath = "_maps/templates/holodeck_anthophillia.dmm"
	restricted = TRUE

/*
/datum/map_template/holodeck/lounge/New()
	. = ..()
	whitelisted_turfs = typecacheof(/turf/closed/mineral)
	banned_objects = typecacheof(/obj/structure/stone_tile)
*/
/*
/datum/map_template/shelter/beta
	name = "Shelter Beta"
	shelter_id = "shelter_beta"
	description = "An extremely luxurious shelter, containing all \
		the amenities of home, including carpeted floors, hot and cold \
		running water, a gourmet three course meal, cooking facilities, \
		and a deluxe companion to keep you from getting lonely during \
		an ash storm."
	mappath = "_maps/templates/shelter_2.dmm"

/datum/map_template/shelter/beta/New()
	. = ..()
	whitelisted_turfs = typecacheof(/turf/closed/mineral)
	banned_objects = typecacheof(/obj/structure/stone_tile)

/datum/map_template/shelter/charlie
	name = "Shelter Charlie"
	shelter_id = "shelter_charlie"
	description = "A luxury elite bar which holds an entire bar \
		along with two vending machines, tables, and a restroom that \
		also has a sink. This isn't a survival capsule and so you can \
		expect that this won't save you if you're bleeding out to \
		death."
	mappath = "_maps/templates/shelter_3.dmm"

/datum/map_template/shelter/charlie/New()
	. = ..()
	whitelisted_turfs = typecacheof(/turf/closed/mineral)
	banned_objects = typecacheof(/obj/structure/stone_tile)
	*/
