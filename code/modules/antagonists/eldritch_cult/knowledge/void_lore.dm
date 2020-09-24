/datum/eldritch_knowledge/base_void
	name = "Glimmer of Winter"
	desc = "Opens up the path of void to you. Allows you to transmute a knife in a sub-zero temperature into a broken blade."
	gain_text = "I feel a shimmer in the air, atmosphere around me gets colder. I feel my body realizing the emptiness of existance. Something's watching me"
	banned_knowledge = list(/datum/eldritch_knowledge/base_ash,/datum/eldritch_knowledge/base_flesh,/datum/eldritch_knowledge/final/ash_final,/datum/eldritch_knowledge/final/flesh_final)
	next_knowledge = list(/datum/eldritch_knowledge/rust_fist)
	required_atoms = list(/obj/item/kitchen/knife,/obj/item/trash)
	result_atoms = list(/obj/item/melee/sickly_blade/rust)
	cost = 1
	route = PATH_VOID

/datum/eldritch_knowledge/base_void/recipe_snowflake_check(list/atoms, loc)
	. = ..()
	var/turf/open/turfie = loc
	if(turfie.temperature > T0C)
		return FALSE

